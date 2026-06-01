# Observations Table
| Column Name | Data Type | Description                                                                        |
| ----------- | --------- | ---------------------------------------------------------------------------------- |
| DATE        | Timestamp | Date and time when the observation was recorded.                                   |
| PATIENT     | UUID      | Unique identifier for the patient.                                                 |
| ENCOUNTER   | UUID      | Unique identifier linking the observation to a specific encounter.                 |
| CODE        | String    | Standardized clinical code representing the observation type.                      |
| DESCRIPTION | String    | Human-readable description of the observation (e.g., Body Weight, Blood Pressure). |
| VALUE       | Numeric   | Recorded measurement value.                                                        |
| UNITS       | String    | Unit of measurement associated with the value (e.g., kg, cm, mmHg).                |
| TYPE        | String    | Data type of the observation value (e.g., numeric).                                |

# Example Observations
- Body Height (cm)
- Body Weight (kg)
- Body Mass Index (BMI)
- Blood Pressure
- Pain Severity Score

# Encounters Table
| Column Name         | Data Type | Description                                                              |
| ------------------- | --------- | ------------------------------------------------------------------------ |
| Id                  | UUID      | Unique identifier for the encounter.                                     |
| START               | Timestamp | Date and time when the encounter began.                                  |
| STOP                | Timestamp | Date and time when the encounter ended.                                  |
| PATIENT             | UUID      | Unique identifier for the patient.                                       |
| ORGANIZATION        | UUID      | Identifier for the healthcare organization where the encounter occurred. |
| PROVIDER            | UUID      | Identifier for the healthcare provider involved in the encounter.        |
| PAYER               | UUID      | Identifier for the insurance provider or payer.                          |
| ENCOUNTERCLASS      | String    | Category of encounter (e.g., wellness, ambulatory).                      |
| CODE                | Integer   | Standardized code representing the encounter type.                       |
| DESCRIPTION         | String    | Description of the encounter.                                            |
| BASE_ENCOUNTER_COST | Numeric   | Base cost associated with the encounter.                                 |
| TOTAL_CLAIM_COST    | Numeric   | Total amount claimed for the encounter.                                  |
| PAYER_COVERAGE      | Numeric   | Amount covered by the payer/insurance provider.                          |
| REASONCODE          | Numeric   | Standardized code for the diagnosis or reason for the encounter.         |
| REASONDESCRIPTION   | String    | Description of the diagnosis or condition associated with the encounter. |

# Example Encounter Types
- General Examination of Patient
- Wellness Visit
- Ambulatory Visit
- Symptom-Related Consultation
