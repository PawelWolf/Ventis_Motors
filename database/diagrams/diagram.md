```mermaid
erDiagram
    Series ||--o{ Cars : "defines"
    Statuses ||--o{ Cars : "tracks"
    BodyTypes ||--o{ Cars : "shapes"
    Engines ||--o{ Cars : "powers"
    
    Cars ||--o{ Sales : "is sold via"
    Customers ||--o{ Sales : "buys"
    Employees ||--o{ Sales : "processes"
    
    Cars ||--o{ ServiceHistory : "undergoes"
    Employees ||--o{ ServiceHistory : "performs"
    
    ServiceHistory ||--o{ ServiceParts : "consumes"
    Parts ||--o{ ServiceParts : "is used in"

    Series {
        int SeriesID PK
        string SeriesName
        string Description
    }
    Statuses {
        int StatusID PK
        string StatusName
    }
    BodyTypes {
        int BodyTypeID PK
        string TypeName
    }
    Engines {
        int EngineID PK
        float Capacity
        string FuelType
        int Horsepower
    }
    Cars {
        int CarID PK
        int SeriesID FK
        int BodyTypeID FK
        int EngineID FK
        int StatusID FK
        string Colour
        decimal Price
        int ProductionYear
    }
    Customers {
        int CustomerID PK
        string FirstName
        string LastName
        string Email
        string Phone
    }
    Employees {
        int EmployeeID PK
        string FirstName
        string LastName
        string Position
    }
    Sales {
        int SaleID PK
        int CarID FK
        int CustomerID FK
        int EmployeeID FK
        datetime SaleDate
        decimal FinalPrice
    }
    ServiceHistory {
        int ServiceID PK
        int CarID FK
        int EmployeeID FK
        datetime ServiceDate
        decimal LaborCost
        string Description
    }
    ServiceParts {
        int ServiceID PK_FK
        int PartID PK_FK
        int Quantity
    }
    Parts {
        int PartID PK
        string PartIndex
        string PartName
        decimal UnitPrice
        int StockQuantity
    }
    ```