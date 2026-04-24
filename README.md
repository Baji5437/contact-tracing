# Contact Tracing Application

A **Salesforce-based contact tracing system** designed to track and manage disease spread by monitoring health statuses, tracking location visits, and automatically updating contact networks.

## Overview

This application helps public health organizations:
- Track individual health statuses (Green → Yellow → Orange → Red)
- Monitor location visits and calculate risk scores
- Automatically trace and notify contacts
- Maintain data efficiency with scheduled cleanup

## Key Features

- **Automated Contact Tracing** - Intelligent propagation through contact networks
- **Health Status Management** - Real-time status updates for contacts
- **Location Risk Scoring** - Calculate risk based on visitor health density
- **Data Privacy** - Unique token generation for individuals
- **Scheduled Automation** - Daily batch jobs for cleanup and updates

## Technology Stack

- **Platform**: Salesforce (Apex)
- **Languages**: Apex, SOQL, XML
- **Frontend**: Lightning Web Components(Aura), Flexipages
- **Tools**: SFDX CLI, ESLint, Prettier, Jest

## Project Structure

```
force-app/main/default/
├── classes/          # Apex controllers and trigger handlers
├── objects/          # Custom objects (Person, Location, People_Tracing, Location_Tracing)
├── triggers/         # Trigger logic
├── layouts/          # Record layouts
├── flexipages/       # Lightning page configurations
├── permissionsets/   # Permission configurations
└── tabs/            # Custom tabs
```

## Setup & Installation

```bash
# Clone the repository
git clone https://github.com/Baji5437/contact-tracing.git
cd contact-tracing

# Install dependencies
npm install

# Code quality checks
npm run lint:lwc
npm run prettier:verify

# Run tests
npm run test:unit
```

## Deployment

```bash
# Deploy to Salesforce org
sfdx force:source:deploy -p force-app/main/default -u your-org-alias
```

## Data Model

| Object | Purpose |
|---|---|
| **Person__c** | Individual records with health status tracking |
| **Location__c** | Physical locations with risk scoring |
| **People_Tracing__c** | Contact relationships between individuals |
| **Location_Tracing__c** | Visit history linking people to locations |

## Core Components

### Apex Controllers
- **CTPersonController** - Manages person records and contact classification
- **CTLocationController** - Handles location risk scoring
- **CTPeopleTracingController** - Tracks contact relationships
- **CTLocationTracingController** - Manages location visits

### Automation
- **Trigger Handlers** - Manage record lifecycle events
- **Batch Jobs** - Process large datasets and cleanup old records
- **Schedulers** - Run batch jobs on schedule (daily at 2:00 AM UTC)

## How It Works

1. When a person's health status changes to RED
2. Automatic triggers identify all their contacts
3. Contact statuses are updated based on relationship type
4. Location risk scores are recalculated
5. Old data is cleaned up automatically

## License

This project is developed as a part of my salesforce learning Journey

## Author

**Baji5437** - Salesforce Platform Development
