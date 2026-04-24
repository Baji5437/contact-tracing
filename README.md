# Contact Tracing Application

A comprehensive **Salesforce-based contact tracing system** designed to track and manage the spread of diseases by monitoring individual health statuses, tracking movements across locations, and intelligently updating contact statuses based on contact relationships.

## 🎯 Project Overview

This application provides a scalable solution for public health organizations to:
- **Track individuals** and their health statuses (Green/Yellow/Orange/Red)
- **Monitor locations** visited by individuals and calculate risk scores
- **Trace contacts** (Cohabitants, Neighbors, Primary/Secondary contacts)
- **Automate health status propagation** through contact networks
- **Perform intelligent data cleanup** to maintain database efficiency

## 🏗️ Architecture & Components

### **Data Model**

#### **Core Objects**
1. **Person__c** - Individual records with health status tracking
   - Fields: Name, Mobile, Health_Status__c, Token__c, Status_Update_Date__c
   - Health Statuses: Green → Yellow → Orange → Red
   - Unique Token: MD5-based hash for privacy and identification

2. **Location__c** - Physical locations where individuals visit
   - Fields: Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c
   - Status determined by Red_Score (count of RED-status visitors in last 10 days)

3. **People_Tracing__c** - Contact records between individuals
   - Fields: Person_1__c, Person_2__c, Contact_Date__c, Contact_Type__c
   - Contact Types: Cohabitant, Neighbor, Other
   - Tracks 30-day contact history

4. **Location_Tracing__c** - Visit records linking individuals to locations
   - Fields: Person__c, Location__c, Visit_Date__c
   - Tracks 10-day visit history for risk assessment

---

## 🔧 Technical Implementation

### **Apex Controllers**

#### **1. CTPersonController** - Person Management
**Responsibilities:**
- Generate unique MD5-based tokens for individuals
- Retrieve recent health status changes (last 100 updates)
- Search individuals by name, mobile, or token
- Calculate health status statistics (count by status)
- **Core Algorithm: Contact Classification**
  - **getAllCohabitants()** - Identifies household contacts to update to ORANGE status
  - **getAllNeighbours()** - Identifies neighborhood contacts to update to YELLOW status
  - **getAllPrimaryContacts()** - Identifies contacts within 10 days to update to ORANGE status
  - **getAllSecondaryContacts()** - Identifies secondary chain contacts to update to YELLOW status

**Key Features:**
- Prevents duplicate processing using `alreadyProcessed` set
- Uses bidirectional relationship queries (Person_1__c OR Person_2__c)
- Implements priority hierarchy: Cohabitant > Primary Contact > Neighbor > Secondary Contact

#### **2. CTLocationController** - Location Management
**Responsibilities:**
- Retrieve locations by ID or search criteria
- Calculate location health statuses based on RED_SCORE
- **Risk Score Algorithm:**
  - GREEN: 0 RED-status visitors in last 10 days
  - YELLOW: 1-5 RED-status visitors
  - ORANGE: 6-10 RED-status visitors
  - RED: >10 RED-status visitors

**Location Status Calculation:**
```
Red_Score = COUNT(Location_Tracing where Person.Health_Status = 'RED' 
                  AND Visit_Date in last 10 days)
```

#### **3. CTPeopleTracingController** - Contact Tracing
**Responsibilities:**
- Retrieve all contacts for a person (30-day history)
- **Duplicate Prevention:** checkDuplicates() method using bidirectional map matching
- Efficiently handles reverse relationships (Person1→Person2 and Person2→Person1)

#### **4. CTLocationTracingController** - Location Tracing
**Responsibilities:**
- Retrieve location visits by person
- Track 10-day visit history for risk assessment

---

### **Trigger Handlers**

#### **1. CTPersonTriggerHandler** - Person Record Operations
**Before Insert:**
- Initializes Health_Status__c to 'Green'
- Generates unique Token__c using MD5 hash of mobile number

**Before Update:**
- Updates Status_Update_Date__c when Health_Status__c changes

**After Update (Complex Business Logic):**
- **Propagates health status changes** to contact network:
  - RED → Updates Cohabitants to ORANGE
  - RED → Updates Primary Contacts to ORANGE
  - RED → Updates Neighbors to YELLOW
  - RED → Updates Secondary Contacts to YELLOW
- **Updates Location Risk Scores** by calling CTLocationController.updateRedScore()
- Uses `alreadyProcessed` set to prevent cascading duplicate updates

#### **2. CTLocationTriggerHandler** - Location Record Operations
- Handles location record lifecycle events

#### **3. CTLocationTracingTriggerHandler** - Location Visit Operations
- Manages location tracing record events

#### **4. CTPeopleTracingTriggerHandler** - Contact Record Operations
- Manages people tracing record events

---

### **Batch Jobs & Schedulers**

#### **1. CTPeopleHealthStatusUpdateBatch** - Health Status Reset
**Schedule:** Runs daily at 2:00 AM via CTStatusUpdateSchedule
**Logic:**
- Queries all Person records with Health_Status IN ('Red','Orange','Yellow')
- WHERE Status_Update_Date__c < 14 days ago
- **Action:** Reset Health_Status to 'Green'
- **Purpose:** Automatic recovery after 14-day quarantine period
- **Batch Size:** 2000 records per batch

#### **2. CTLocationStatusUpdateBatch** - Location Status Reset
**Schedule:** Runs daily via CTStatusUpdateSchedule
**Logic:**
- Resets Location statuses when risk conditions change
- Batch Size: 2000 records

#### **3. CTPeopleTracingDataCleanUpBatch** - Contact Record Cleanup
**Schedule:** Runs daily at 2:00 AM via CTDataCleanUpSchedule
**Logic:**
- Removes old People_Tracing__c records (>30 days old)
- Maintains data freshness and performance
- Batch Size: 2000 records

#### **4. CTLocationTracingCleanUpBatch** - Location Visit Cleanup
**Schedule:** Runs daily at 2:00 AM via CTDataCleanUpSchedule
**Logic:**
- Removes old Location_Tracing__c records (>10 days old)
- Prevents database bloat

#### **5. CTDataCleanUpSchedule** - Master Scheduler
```
Cron Expression: '0 0 2 * * ?' (Daily at 2:00 AM UTC)
Orchestrates: 
  - CTPeopleTracingDataCleanUpBatch
  - CTLocationTracingCleanUpBatch
```

#### **6. CTStatusUpdateSchedule** - Status Batch Scheduler
**Schedule:** Triggers health and location status update batches

---

## 🔄 Workflow & Business Logic

### **Health Status Update Flow**

```
Person A Health Status Changes to RED
         ↓
CTPersonTriggerHandler.afterUpdateHandler() Triggered
         ↓
    ├─→ Get All COHABITANTS → Update to ORANGE
    ├─→ Get All PRIMARY CONTACTS (10-day window) → Update to ORANGE
    ├─→ Get All NEIGHBORS → Update to YELLOW
    └─→ Get All SECONDARY CONTACTS → Update to YELLOW
         ↓
Update Location Risk Scores for all locations visited by affected persons
         ↓
Location Status Updated Based on Red_Score Algorithm
```

### **Contact Classification**

| Contact Type | Condition | Action | Status |
|---|---|---|---|
| **Cohabitant** | Person 1 or 2 has RED status | Update other to ORANGE | High Priority |
| **Primary Contact** | Contact within 10 days, person in Green/Yellow | Update to ORANGE | High Priority |
| **Neighbor** | Person 1 or 2 has RED status | Update other to YELLOW | Medium Priority |
| **Secondary Contact** | Contact through Primary (10-day window) | Update to YELLOW | Low Priority |

### **Data Cleanup Strategy**

- **People_Tracing__c:** Retained for 30 days (rolling window)
- **Location_Tracing__c:** Retained for 10 days (rolling window)
- **Person Health Status:** Green reset after 14 days of last status update
- **Location Status:** Updated daily based on active RED visitors

---

## 💻 Technical Stack

- **Platform:** Salesforce (Apex)
- **Languages:** Apex, XML (metadata)
- **Frontend:** Lightning Web Components (Aura), Flexipages
- **Development Tools:** SFDX CLI, Prettier, ESLint
- **Testing:** Jest (LWC unit tests)

---

## 📋 Key Features

✅ **Automated Contact Tracing** - Intelligent propagation through contact networks
✅ **Health Status Management** - Automatic progression and recovery cycles
✅ **Location Risk Assessment** - Real-time risk scoring based on visitor health status
✅ **Data Privacy** - MD5-based tokenization for individual identification
✅ **Performance Optimization** - Scheduled batch jobs and data cleanup
✅ **Scalability** - Batch processing for large datasets
✅ **Duplicate Prevention** - Bidirectional relationship checking

---

## 🚀 Development & Deployment

### **Setup**
```bash
# Clone repository
git clone https://github.com/Baji5437/contact-tracing.git
cd contact-tracing

# Install dependencies
npm install

# Code formatting & linting
npm run prettier
npm run lint:lwc
```

### **Testing**
```bash
# Run unit tests
npm run test:unit

# Watch mode
npm run test:unit:watch

# Coverage report
npm run test:unit:coverage
```

### **Deployment**
```bash
# Using SFDX CLI
sfdx force:source:deploy -p force-app/main/default
```

---

## 📊 Database Structure

```
Person__c
├── Name
├── Mobile__c (unique identifier)
├── Health_Status__c (Green/Yellow/Orange/Red)
├── Token__c (MD5 hash)
└── Status_Update_Date__c

Location__c
├── Name
├── Address__c
├── Pincode__c
├── Red_Score__c (aggregated count)
└── Status__c (derived from Red_Score)

People_Tracing__c (Junction)
├── Person_1__c (Lookup)
├── Person_2__c (Lookup)
├── Contact_Date__c
└── Contact_Type__c (Cohabitant/Neighbor/Other)

Location_Tracing__c (Junction)
├── Person__c (Lookup)
├── Location__c (Lookup)
└── Visit_Date__c
```

---

## 🎓 Educational Value

This project demonstrates:
- **Advanced Apex Patterns:** Trigger handlers, batch processing, scheduled jobs
- **Efficient Data Querying:** Aggregate functions, relationship queries, performance optimization
- **Complex Business Logic:** Graph traversal (contact chains), status propagation
- **Data Model Design:** Junction objects, custom fields, status management
- **Salesforce Best Practices:** Separation of concerns, scalable architecture
- **Automation:** Scheduled jobs, batch processing, async operations


## 👨‍💻 Author

**Baji5437** - Salesforce Platform Development

---

