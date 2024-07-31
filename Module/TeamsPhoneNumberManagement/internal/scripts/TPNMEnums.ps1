# Enumeration of all available tables in the SQL database.
# This is used to split the parameter names in the module functions on the correct position to identity the table and column name provided.
enum TPNMDatabaseTable {
    Country = 0
    Forbidden = 1
    Department = 2
    ExtRange = 3
    Allocation = 4
}

# Enumeration of allowed values for 'State' in allocation table
enum TPNMAllocationState {
    Requested = 0
    Assigned = 1
    Blocked = 2
}