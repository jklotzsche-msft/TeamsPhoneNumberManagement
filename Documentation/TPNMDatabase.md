# TeamsPhoneNumberManagement Database Documentation

This document provides a detailed description of the tables in the TPNM database.
You can use this document as a reference when working with the database.

Please refer to the [Database Deployment Script](./TPNMDatabase.sql) for the SQL script that creates the tables. The [deployment guide](../Deployment.md) provides instructions on how to deploy and configure the database.
You can use the PowerShell Module [TeamsPhoneNumberManagement](../../Module/TeamsPhoneNumberManagement/) or [Azure portal query editor](https://learn.microsoft.com/en-us/azure/azure-sql/database/query-editor?view=azuresql) to query or add data to the tables after creating them.

## Table: Country

The `Country` table stores information about different countries.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ID | INT | The primary key of the table. |
| Name | VARCHAR(2) | The name of the country. Should be in the ISO3166-1 alpha-2 format. |
| Code | VARCHAR(4) | The country code. Should be in the E.164 format. |
| Description | VARCHAR(100) | A brief description of the country. |

### Constraints for the Country Table

The `Country` table has a constraint `CHK_Code` that validates that the country code is in the E.164 format.

## Table: Forbidden

The `Forbidden` table stores information about forbidden extensions in different countries.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ID | INT | The primary key of the table. |
| Country | INT | The ID of the country where the forbidden extension is located. This is a foreign key referencing the `Country` table. |
| Extension | VARCHAR(15) | The forbidden phone extension for this country. |
| Description | VARCHAR(100) | A brief description of the forbidden extension. |

### Constraints for the Forbidden Table

The `Forbidden` table has a constraint `UC_Extension_Country` that ensures that the combination of `Extension` and `Country` is unique.

## Table: Department

The `Department` table stores information about different departments.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ID | INT | The primary key of the table. |
| Country | INT | The ID of the country where the department is located. This is a foreign key referencing the `Country` table. |
| Name | VARCHAR(15) | The name of the department. |
| Description | VARCHAR(100) | A brief description of the department. |

### Constraints for the Department Table

The `Department` table has a constraint `UC_Name_Country` that ensures that the combination of `Name` and `Country` is unique.

## Table: ExtRange

The `ExtRange` table stores information about extension ranges for different departments.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ID | INT | The primary key of the table. |
| Department | INT | The ID of the department that the extension range belongs to. This is a foreign key referencing the `Department` table. |
| Span | VARCHAR(15) | The span of the extension range. |
| SpanStart | VARCHAR(15) | The start of the extension range. |
| SpanEnd | VARCHAR(15) | The end of the extension range. |
| Description | VARCHAR(100) | A brief description of the extension range. |

### Constraints for the ExtRange Table

The `ExtRange` table has a constraint `UC_Department_Span_SpanStart_SpanEnd` that ensures that the combination of `Department`, `Span`, `SpanStart`, and `SpanEnd` is unique.

## Table: Allocation

The `Allocation` table stores information about allocated extensions.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| ID | INT | The primary key of the table. |
| ExtRange | INT | The ID of the extension range that the extension belongs to. This is a foreign key referencing the `ExtRange` table. |
| Extension | VARCHAR(15) | The allocated phone extension. |
| State | VARCHAR(50) | The state of the allocation. The state could be 'Requested', 'Blocked' or 'Assigned'. |
| CreatedOn | DATETIME | The date and time when the allocation was created. |
| Description | VARCHAR(100) | A brief description of the allocation. |

### Constraints for the Allocation Table

The `Allocation` table has a constraint `UC_ExtRange_Extension` that ensures that the combination of `ExtRange` and `Extension` is unique.