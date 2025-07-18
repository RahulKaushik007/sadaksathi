# Sadak Sathi Project Workflow Diagram

```mermaid
flowchart TD
    A[User Registration/Login] --> B[Identify Civic Issue]
    B --> C[Select Location on Map]
    C --> D[Upload Photos/Evidence]
    D --> E[Submit Complaint Form]
    E --> F[System Categorizes Issue]
    F --> G[Automated Routing to Authorities]
    G --> H[Authorities Review Complaint]
    H --> I{Issue Valid?}
    I -->|Yes| J[Assign Priority Level]
    I -->|No| K[Reject with Reason]
    J --> L[Update Status: Under Investigation]
    L --> M[Authorities Take Action]
    M --> N[Update Status: Work in Progress]
    N --> O[Complete Resolution]
    O --> P[Update Status: Resolved]
    P --> Q[Notify User of Resolution]
    Q --> R[User Provides Feedback]
    R --> S[System Records Resolution Data]
    S --> T[Generate Analytics Report]
    
    K --> U[Notify User of Rejection]
    U --> V[User Can Appeal/Resubmit]
    V --> E
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fce4ec
    style F fill:#f1f8e9
    style G fill:#e0f2f1
    style H fill:#fff8e1
    style I fill:#fce4ec
    style J fill:#e8f5e8
    style L fill:#e3f2fd
    style M fill:#f3e5f5
    style N fill:#e8f5e8
    style O fill:#fff3e0
    style P fill:#e1f5fe
    style Q fill:#f1f8e9
    style R fill:#e0f2f1
    style S fill:#fff8e1
    style T fill:#fce4ec
    style K fill:#ffebee
    style U fill:#ffebee
    style V fill:#fff3e0
```

## Workflow Description

### Phase 1: User Engagement
1. **User Registration/Login** - Users create accounts or log in to access the platform
2. **Identify Civic Issue** - Users identify problems like potholes, broken streetlights, etc.
3. **Select Location on Map** - Users pinpoint exact location using interactive maps
4. **Upload Photos/Evidence** - Users provide visual evidence of the issue
5. **Submit Complaint Form** - Users complete and submit the complaint

### Phase 2: System Processing
6. **System Categorizes Issue** - AI/automated system categorizes the complaint type
7. **Automated Routing to Authorities** - System routes complaint to appropriate department
8. **Authorities Review Complaint** - Municipal staff review the submitted complaint

### Phase 3: Issue Resolution
9. **Issue Validation** - Authorities validate if the issue is legitimate
10. **Priority Assignment** - Valid issues are assigned priority levels
11. **Status Updates** - System tracks progress through various stages
12. **Action Implementation** - Authorities take physical action to resolve the issue
13. **Resolution Completion** - Issue is resolved and marked as complete

### Phase 4: Feedback & Analytics
14. **User Notification** - Users are notified of resolution
15. **User Feedback** - Users provide feedback on resolution quality
16. **Data Recording** - System records all resolution data
17. **Analytics Generation** - System generates reports for authorities

### Alternative Path: Issue Rejection
- If issue is invalid, authorities can reject with reasons
- Users are notified and can appeal or resubmit
- Rejected complaints can be resubmitted with additional information

## Key Features of the Workflow

- **Transparency**: All steps are visible to users
- **Accountability**: Each action is tracked and recorded
- **Efficiency**: Automated routing reduces delays
- **Feedback Loop**: Continuous improvement through user feedback
- **Data Analytics**: Insights for better resource allocation 