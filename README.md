PawSure Pet Insurance – SQL Data Engineering + BA Case Study
Author: Soundarya Sainathan
Hybrid Role Target: SQL Developer + Business Analyst
-------------------------------------------------------------------------------------------
Project Snapshot
Imagine this:

   You’re a part of a fast-growing pet insurance company, and one morning the finance team flags something worrying: “Our claim payouts are up, and it’s hitting us hardest on orthopedic surgeries. Why?”

This project is my answer — blending tech and business to find the real story behind the numbers.
You’ll see both the Business Analyst’s investigation and the SQL Developer’s toolkit in action.
------------------------------------------------------------------------------------------------
What’s the Burning Question?
Why are our claim payout costs climbing every month — and how do we fix it?

The Business Angle (BA Case Study)
---------------------------------
   I mapped the entire business problem:

   * Where PawSure stands
   * What’s going wrong
   * Who’s impacted most
   * The KPIs that matter
   * Biggest pain points
   * Realistic action steps

Explore the full narrative here:
/docs/01_BA_Case_Study.md 
------------------------------------------------------------------------------------------------------

The Technical Angle (SQL + ETL)
------------------------------
Here’s the heart of my technical build:
   * Powered by SQL Server (T-SQL) and managed in SSMS
   * Simulates incoming claim data (via “Azure Blob Storage” scenario)
   * Fact and Dimension Modeling:
       * Dimensions for Pet, Disease, Clinic, City
       * FactClaim to track actual claims (plus a flag for fraud risk)
* ETL Pipeline:
   * Stages raw claims, logs rejects
   * Automated transform & validate workflows
* KPI Dashboards:
   * Claims cost trends, SLA bottlenecks, risk & fraud insights

| Tech Piece                 | What it Does for Us                                                                        |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| Schema & Dimensions        | Breaks down data by pet type, disease, clinic, and city so we can slice insights           |
| FactClaim Table            | Tracks every claim, with a built-in fraud signal                                           |
| ETL Staging Model          | Catches dirty data before it hits our dashboard                                            |
| Transform Stored Procedure | Automates the load, validates data, keeps integrity                                        |
| KPI Views                  | Show us exactly where money is leaking, what’s slowing us down, and where risks are hiding |

Architecture: How It All Fits Together
--------------------------------------
Picture this pipeline:
  * Raw claim files (e.g. from vet clinics) land in Blob Storage
  * ETL kicks in — pulling, validating, and staging the data
  * Anything dodgy (wrong formats, strange costs) gets logged in Rejects
  * Valid claims flow into the FactClaim table, tagged for possible fraud where needed
  * Dim tables (Pet, Disease, Clinic, City) make every report relatable and drill-down ready
  * KPI Views crunch the numbers and fuel business decisions

In short:
--------
This project isn’t just about clean code or smart queries. It’s about connecting SQL chops with business sense—so the numbers start telling stories, the risks get caught early, and pets (and pet parents) get the best care, sustainably.
In short:
This project isn’t just about clean code or smart queries. It’s about connecting SQL chops with business sense—so the numbers start telling stories, the risks get caught early, and pets (and pet parents) get the best care, sustainably.
