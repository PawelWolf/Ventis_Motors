# 🏎️ Ventis Motors - Car Dealership Management System

A comprehensive web application designed for car dealership management, integrating advanced Object-Oriented Programming (OOP) principles in Python with a robust cloud-based relational database architecture.

---

## 🌐 Cloud Deployment Links

The application has been successfully deployed and can be accessed via the following channells:
* **Legacy SQLite Version:** [http://ventis-motors-app.azurewebsites.net/](http://ventis-motors-app.azurewebsites.net/)
* **Production Azure T-SQL Version:** [https://ventis-motors-app-2-db.azurewebsites.net/](https://ventis-motors-app-2-db.azurewebsites.net/)

---

## 🚀 Local Installation & Quick Start

Follow these steps to run the Flask web server locally on your development machine.

### 1. Prerequisites
Ensure you have Python 3.11+ installed. For the Azure T-SQL database connectivity, you also need the Microsoft ODBC Driver installed on your operating system.

### 2. Environment Setup
Clone the repository and install the required dependencies:
```bash
# Clone the repository (replace with your actual URL)
git clone [https://github.com/pawelwolf/Ventis_Motors.git](https://github.com/pawelwolf/Ventis_Motors.git)
cd Ventis_Motors

# Install Python packages
pip install -r requirements.txt

### 3. Runnning the Application
Execute the primary script to initialization the Flask development server:

Bash
python app.py

Once initialized, open your web browser and navigate to:
👉 http://127.0.0.1:5000

OOP Concept / Pattern,Implementation Details
Inheritance,AvailableCar and SoldCar classes inherit from the base Car class.
Attribute Overriding,"Descendant classes like PremiumCar explicitly introduce and override attributes (e.g., _warranty_years)."
Method Overriding,Custom implementations of native methods like __str__ across class hierarchies.
Decorators,Extensive utilization of @classmethod (alternative constructors) and @staticmethod.
Multiple Constructors,CarFactory handles flexible object creation from database rows or web form inputs.
Encapsulation,Strict data hiding using private attributes (prefixed with _) exposed safely via explicit getters and setters with internal data validation.
Polymorphism,Runtime interface flexibility allowing unified interactions with varying car types.
Parent Class Execution,Leverages super().__init__() to preserve and extend base constructor and method behaviors.
Custom Exception Handling,Defined CarNotAvailableException inheriting from the built-in Exception class for robust domain error handling.
Strategy Pattern,Encapsulates distinct operational behaviors for cars based on their current business status (Available vs. Sold).
Command Pattern,Implemented through encapsulation workflows like ResetCarCommand to trigger state alterations.
Template Method Pattern,Codified within CarPurchaseTemplate to enforce a skeletal algorithm structure for vehicle processing while deferring exact steps to subclasses.

📊 SQL Database Architecture Specification
The data layer is engineered to model a production-grade relational ecosystem capable of maintaining strict transactional integrity.

Core Database Architecture:
Schema Blueprint: Designed an explicit data layout spanning 8 tightly-coupled relational tables (exceeding the 6-10 minimum limit), ensuring logical constraints and foreign key mappings.

Transactional Reality Simulation: Native workflows execute data manipulation patterns including INSERT actions (new customer ingestion), UPDATE routines (promotional batch price updates), and DELETE queries complying with data privacy/GDPR mechanics.

Advanced Analytical Reports: Includes 5 sophisticated database queries using complex relational techniques:

Transactional revenue aggregation grouped by specific car Series using multiple inner table joins.

Complete matrix compilation of mechanical, core, and financial criteria per vehicle.

High-tier customer profiling through financial aggregation and sorting filters.

Employee sales performance tracking leveraging GROUP BY accompanied by conditional HAVING filters.

Multi-year business tracking using temporal extraction functions (YEAR()).

👥 Authors & Team Credits

Paweł Wolf
Konrad Skrzypek
Oliwier Pol
Ivo Czura

🔒 All copyrights reserved © 2026