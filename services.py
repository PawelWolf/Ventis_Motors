from models import CarNotAvailableException


class CarPurchaseTemplate:
    """
    Klasa implementująca wzorzec Template Method Pattern.

    Użycie klas: Definiuje szablon procesu zakupu samochodu
    Użycie dziedziczenia: Klasa bazowa dla konkretnych implementacji zakupu
    Użycie metod w klasach: Zawiera metody purchase() i abstrakcyjną process_purchase()
    Wzorzec Template Method: Metoda purchase() definiuje szablon algorytmu,
    delegując szczegóły implementacji do metody process_purchase() w klasach potomnych
    """

    def __init__(self, db):
        """
        Konstruktor klasy CarPurchaseTemplate.

        Użycie atrybutów w klasach: self.db przechowuje referencję do bazy danych

        Args:
            db: Obiekt bazy danych do zarządzania samochodami
        """
        self.db = db

    def purchase(self, body, engine, drive, colour):
        """
        Metoda szablonowa definiująca proces zakupu samochodu.

        Template Method Pattern: Definiuje szkielet algorytmu zakupu,
        delegując szczegóły do metody process_purchase()

        Args:
            body: Typ nadwozia samochodu
            engine: Typ silnika
            drive: Typ napędu
            colour: Kolor samochodu

        Returns:
            Cena samochodu po przetworzeniu zakupu

        Raises:
            Exception: Gdy samochód nie zostanie znaleziony
        """
        car = self.db.find_car(body, engine, drive, colour)
        if not car:
            raise Exception("Car not found!")

        price = self.process_purchase(car)
        self.db.update_car_status(car.car_id, car.sold)
        return price

    def process_purchase(self, car):
        """
        Abstrakcyjna metoda do implementacji w klasach potomnych.

        Użycie metod w klasach: Metoda abstrakcyjna wymagająca implementacji
        w klasach dziedziczących

        Args:
            car: Obiekt samochodu do przetworzenia

        Raises:
            NotImplementedError: Gdy metoda nie jest zaimplementowana
        """
        raise NotImplementedError


class ClientPurchase(CarPurchaseTemplate):
    """
    Konkretna implementacja zakupu dla klientów.

    Użycie dziedziczenia: Dziedziczy po CarPurchaseTemplate
    Pokazanie nadpisywania metod w klasach potomnych: Implementuje process_purchase()
    Polimorfizm: Może być używana wszędzie gdzie oczekiwana jest CarPurchaseTemplate
    Utworzenie i użycie swojego wyjątku: Rzuca CarNotAvailableException
    """

    def process_purchase(self, car):
        """
        Implementacja procesu zakupu dla klientów.

        Pokazanie nadpisywania metod w klasach potomnych: Nadpisuje abstrakcyjną
        metodę z klasy rodzica

        Args:
            car: Obiekt samochodu do zakupu

        Returns:
            Cena samochodu

        Raises:
            CarNotAvailableException: Gdy samochód jest już sprzedany
        """
        if car.sold == 's':
            raise CarNotAvailableException("Car already sold!")
        car.sell()
        return car.price


class Command:
    """
    Klasa bazowa implementująca wzorzec Command Pattern.

    Użycie klas: Definiuje interfejs dla wszystkich poleceń
    Wzorzec Command: Enkapsuluje żądanie jako obiekt, umożliwiając parametryzację
    klientów z różnymi żądaniami
    """

    def execute(self):
        """
        Abstrakcyjna metoda wykonania polecenia.

        Użycie metod w klasach: Metoda bazowa do nadpisania w klasach potomnych
        """
        pass


class ResetCarCommand(Command):
    """
    Konkretne polecenie resetowania statusu pojedynczego samochodu.

    Użycie dziedziczenia: Dziedziczy po Command
    Wzorzec Command: Enkapsuluje operację resetowania samochodu
    Polimorfizm: Może być używane wszędzie gdzie oczekiwany jest Command
    """

    def __init__(self, db, car_id):
        """
        Konstruktor polecenia resetowania samochodu.

        Użycie atrybutów w klasach: Przechowuje db i car_id jako atrybuty instancji

        Args:
            db: Obiekt bazy danych
            car_id: ID samochodu do zresetowania
        """
        self.db = db
        self.car_id = car_id

    def execute(self):
        """
        Wykonanie polecenia resetowania samochodu.

        Pokazanie nadpisywania metod w klasach potomnych: Implementuje metodę
        execute() z klasy Command
        """
        self.db.update_car_status(self.car_id, None)


class ResetAllCarsCommand(Command):
    """
    Konkretne polecenie resetowania wszystkich samochodów.

    Użycie dziedziczenia: Dziedziczy po Command
    Użycie implementacji z klasy rodzica: Wywołuje super().__init__()
    Wzorzec Command: Enkapsuluje operację resetowania wszystkich samochodów
    """

    def __init__(self, db):
        """
        Konstruktor polecenia resetowania wszystkich samochodów.

        Użycie implementacji z klasy rodzica: Wywołuje konstruktor klasy bazowej
        używając super()

        Args:
            db: Obiekt bazy danych
        """
        super().__init__()
        self.db = db

    def execute(self):
        """
        Wykonanie polecenia resetowania wszystkich samochodów.

        Pokazanie nadpisywania metod w klasach potomnych: Implementuje metodę
        execute() z klasy Command
        """
        self.db.reset_all()


# Dodatkowe klasy demonstrujące pozostałe zagadnienia OOP:

class CarDatabase:
    """
    Klasa zarządzająca bazą danych samochodów.

    Użycie enkapsulacji: Zawiera prywatne atrybuty i metody dostępowe
    Klasa zawierająca więcej niż jeden konstruktor: Alternatywne konstruktory
    Użycie dekoratora @classmethod lub @staticmethod: Metody klasowe i statyczne
    """

    def __init__(self, connection_string):
        """
        Główny konstruktor klasy.

        Args:
            connection_string: String połączenia z bazą danych
        """
        self._connection_string = connection_string  # Enkapsulacja - atrybut prywatny
        self._cars = []
        self._total_sales = 0

    @classmethod
    def from_config_file(cls, config_path):
        """
        Alternatywny konstruktor tworzący instancję z pliku konfiguracyjnego.

        Klasa zawierająca więcej niż jeden konstruktor: Alternatywny sposób
        tworzenia instancji klasy
        Użycie dekoratora @classmethod: Metoda klasowa

        Args:
            config_path: Ścieżka do pliku konfiguracyjnego

        Returns:
            Nowa instancja CarDatabase
        """
        # Symulacja wczytania konfiguracji
        connection_string = f"database://localhost/cars_from_{config_path}"
        return cls(connection_string)

    @staticmethod
    def validate_car_data(body, engine, drive, colour):
        """
        Statyczna metoda walidacji danych samochodu.

        Użycie dekoratora @staticmethod: Metoda statyczna niezależna od instancji

        Args:
            body: Typ nadwozia
            engine: Typ silnika
            drive: Typ napędu
            colour: Kolor

        Returns:
            bool: True jeśli dane są poprawne
        """
        return all([body, engine, drive, colour])

    @property
    def total_sales(self):
        """
        Getter dla całkowitej liczby sprzedaży.

        Użycie enkapsulacji: Getter zapewniający kontrolowany dostęp do atrybutu

        Returns:
            Całkowita liczba sprzedaży
        """
        return self._total_sales

    @total_sales.setter
    def total_sales(self, value):
        """
        Setter dla całkowitej liczby sprzedaży.

        Użycie enkapsulacji: Setter z walidacją wartości

        Args:
            value: Nowa wartość sprzedaży

        Raises:
            ValueError: Gdy wartość jest ujemna
        """
        if value < 0:
            raise ValueError("Total sales cannot be negative")
        self._total_sales = value


class PremiumCarPurchase(CarPurchaseTemplate):
    """
    Implementacja zakupu dla klientów premium.

    Użycie dziedziczenia: Dziedziczy po CarPurchaseTemplate
    Pokazanie nadpisywania atrybutów w klasach potomnych: Dodaje discount_rate
    Polimorfizm: Alternatywna implementacja process_purchase()
    """

    def __init__(self, db, discount_rate=0.1):
        """
        Konstruktor dla zakupu premium.

        Użycie implementacji z klasy rodzica: Wywołuje konstruktor bazowy
        Pokazanie nadpisywania atrybutów w klasach potomnych: Dodaje discount_rate

        Args:
            db: Baza danych
            discount_rate: Stopa rabatu dla klientów premium
        """
        super().__init__(db)
        self.discount_rate = discount_rate  # Nowy atrybut w klasie potomnej

    def process_purchase(self, car):
        """
        Implementacja zakupu z rabatem dla klientów premium.

        Pokazanie nadpisywania metod w klasach potomnych: Nadpisuje metodę
        z klasy bazowej z dodatkową funkcjonalnością rabatu

        Args:
            car: Samochód do zakupu

        Returns:
            Cena po rabacie
        """
        if car.sold == 's':
            raise CarNotAvailableException("Car already sold!")
        car.sell()
        return car.price * (1 - self.discount_rate)


class CarSalesStrategy:
    """
    Klasa bazowa dla wzorca Strategy Pattern.

    Wzorzec Strategy: Definiuje rodzinę algorytmów sprzedaży
    """

    def calculate_final_price(self, base_price):
        """
        Metoda obliczania końcowej ceny.

        Args:
            base_price: Cena bazowa

        Returns:
            Końcowa cena
        """
        raise NotImplementedError


class RegularSalesStrategy(CarSalesStrategy):
    """
    Strategia sprzedaży dla zwykłych klientów.

    Wzorzec Strategy: Konkretna implementacja strategii
    """

    def calculate_final_price(self, base_price):
        """Zwykła cena bez rabatu."""
        return base_price


class VIPSalesStrategy(CarSalesStrategy):
    """
    Strategia sprzedaży dla klientów VIP.

    Wzorzec Strategy: Konkretna implementacja strategii z rabatem
    """

    def calculate_final_price(self, base_price):
        """Cena z 15% rabatem dla VIP."""
        return base_price * 0.85


class CarSalesContext:
    """
    Kontekst dla wzorca Strategy Pattern.

    Wzorzec Strategy: Używa różnych strategii sprzedaży
    """

    def __init__(self, strategy: CarSalesStrategy):
        """
        Args:
            strategy: Strategia sprzedaży do użycia
        """
        self._strategy = strategy

    def set_strategy(self, strategy: CarSalesStrategy):
        """Zmienia strategię sprzedaży."""
        self._strategy = strategy

    def execute_sale(self, base_price):
        """
        Wykonuje sprzedaż używając aktualnej strategii.

        Args:
            base_price: Cena bazowa

        Returns:
            Końcowa cena obliczona przez strategię
        """
        return self._strategy.calculate_final_price(base_price)