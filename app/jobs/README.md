# Scanning jobs

There is a fairly complex tree of jobs that happens when models are scanned, which can also be prompted by various actions.

```mermaid
flowchart TD
    DFS[Scan::Library::DetectFileSystemChangesJob]
    CMFP[Scan::Library::CreateModelFromPathJob]
    ANF[Scan::Model::AddNewFilesJob]
    PM[Scan::Model::ParseMetadataJob]
    PMF[Scan::ModelFile::ParseMetadataJob]
    CFP[Scan::Model::CheckForProblemsJob]
    CA[Scan::CheckAllJob]
    CM[Scan::CheckModelJob]
    OM[OrganizeModelJob]
    PUF[ProcessUploadedFileJob]
    AMF[Analysis::AnalyseModelFileJob]
    FC[Analysis::FileConversionJob]
    GA[Analysis::GeometricAnalysisJob]

    ModelEdit([fa:fa-person Model edited])
    Organize([fa:fa-person Organize button])
    ScanAll([fa:fa-person Scan for changes])
    CheckAll([fa:fa-person Rescan all models])
    MainUpload([fa:fa-person Upload button])
    FileUpload([fa:fa-person Upload files in model])
    FileConvert([fa:fa-person Convert file button])

    ScanAll --> DFS
    CheckAll --> CA
    DFS -->|each changed path| CMFP
    CMFP --> ANF
    ANF --> PM
    ANF -->|each new file| PMF
    PM --> CFP
    ModelEdit --> CFP
    PMF --> AMF
    AMF -->|geometric analysis enabled?| GA
    CA -->|each model| CM
    CM -->|scan = true| ANF
    CM -->|scan = false| CFP
    CM -->|each file| AMF
    Organize --> OM
    OM --> CFP
    MainUpload --> PUF
    FileUpload --> PUF
    PUF -->|new model?| ANF
    PUF -->|new file in existing model?| CFP
    PUF -->|new file in existing model?| PMF
    FileConvert --> FC
    FC --> AMF


    classDef queue_analysis fill:#700,stroke:#f00,stroke-width:2px;
    classDef queue_activity fill:#770,stroke:#ff0,stroke-width:2px;
    classDef queue_scan fill:#070,stroke:#0f0,stroke-width:2px;
    classDef queue_default fill:#077,stroke:#0ff,stroke-width:2px;
    classDef queue_performance fill:#007,stroke:#00f,stroke-width:2px;
    classDef queue_upgrade fill:#707,stroke:#f0f,stroke-width:2px;

    class DFS,CA,CM,CMFP,ANF,PM,PMF,CFP queue_scan
    class FC,GA queue_performance
    class AMF queue_analysis
    class OM,PUF queue_default

    classDef user_action fill:#777,stroke:#fff,stroke-width:2px;
    class ModelEdit,Organize,ScanAll,CheckAll,MainUpload,FileUpload,FileConvert user_action

```

Colours correspond to the queue the job uses:

* Green: `scan`
* Red: `analysis`
* Cyan: `default`
* Blue: `performance`

Grey ovals are user-initiated actions (e.g. a button click).
