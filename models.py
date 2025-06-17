import sqlite3


class CarNotAvailableException(Exception):
    """
    Własny wyjątek dziedziczący z Exception.

    Użycie własnego wyjątku:
    - Tworzy specjalistyczny wyjątek dla sytuacji gdy samochód nie jest dostępny
    - Dziedziczy z wbudowanej klasy Exception
    - Pozwala na bardziej precyzyjne zarządzanie błędami w aplikacji
    """
    pass


class Car:
    """
    Bazowa klasa reprezentująca samochód.

    Zastosowane zagadnienia OOP:
    - Użycie klas: podstawowa definicja klasy z atrybutami i metodami
    - Użycie atrybutów w klasach: przechowywanie danych o samochodzie
    - Użycie enkapsulacji: prywatne atrybuty z _ oraz gettery/settery
    - Użycie metod w klasach: __init__, __str__, właściwości

    Attributes:
        _car_id (int): Unikalny identyfikator samochodu (enkapsulowany)
        _body (str): Typ nadwozia (enkapsulowany)
        _engine (str): Typ silnika (enkapsulowany)
        _drive (str): Typ napędu (enkapsulowany)
        _colour (str): Kolor samochodu (enkapsulowany)
        _price (float): Cena samochodu (enkapsulowany)
        _sold (str/None): Status sprzedaży - 's' lub None (enkapsulowany z setterem)
    """

    def __init__(self, car_id, body, engine, drive, colour, price, sold):
        """
        Konstruktor klasy Car.

        Args:
            car_id (int): Identyfikator samochodu
            body (str): Typ nadwozia
            engine (str): Typ silnika
            drive (str): Typ napędu
            colour (str): Kolor
            price (float): Cena
            sold (str/None): Status sprzedaży
        """
        self._car_id = car_id
        self._body = body
        self._engine = engine
        self._drive = drive
        self._colour = colour
        self._price = price
        self._sold = sold

    @property
    def car_id(self):
        """
        Getter dla car_id.

        Użycie enkapsulacji - właściwość tylko do odczytu.

        Returns:
            int: Identyfikator samochodu
        """
        return self._car_id

    @property
    def price(self):
        """
        Getter dla price.

        Użycie enkapsulacji - właściwość tylko do odczytu.

        Returns:
            float: Cena samochodu
        """
        return self._price

    @property
    def sold(self):
        """
        Getter dla sold.

        Użycie enkapsulacji - getter dla statusu sprzedaży.

        Returns:
            str/None: Status sprzedaży
        """
        return self._sold

    @sold.setter
    def sold(self, value):
        """
        Setter dla sold z walidacją.

        Użycie enkapsulacji - setter z walidacją danych.

        Args:
            value (str/None): Nowy status sprzedaży

        Raises:
            ValueError: Gdy status nie jest 's' ani None
        """
        if value not in ('s', None):
            raise ValueError("Invalid sold status")
        self._sold = value

    def __str__(self):
        """
        Reprezentacja tekstowa obiektu.

        Użycie metod w klasach - nadpisanie wbudowanej metody __str__.

        Returns:
            str: Opis samochodu
        """
        return f"{self._body} {self._engine} {self._drive} {self._colour} - {self._price} - {self._sold or 'Not Sold'}"


class AvailableCar(Car):
    """
    Klasa reprezentująca dostępny samochód.

    Zastosowane zagadnienia OOP:
    - Użycie dziedziczenia: dziedziczy po klasie Car
    - Użycie metod w klasach: dodaje metodę sell()
    - Polimorfizm: obiekty tej klasy mogą być używane jako Car

    Wzorzec projektowy: Strategia (Strategy)
    - Różne strategie obsługi samochodów (dostępny vs sprzedany)
    - AvailableCar implementuje strategię dla dostępnych samochodów
    """

    def sell(self):
        """
        Sprzedaż samochodu.

        Sprawdza czy samochód nie jest już sprzedany, następnie zmienia status.

        Returns:
            float: Cena samochodu

        Raises:
            CarNotAvailableException: Gdy samochód jest już sprzedany
        """
        if self.sold == 's':
            raise CarNotAvailableException("Car already sold!")
        self.sold = 's'
        return self.price


class SoldCar(Car):
    """
    Klasa reprezentująca sprzedany samochód.

    Zastosowane zagadnienia OOP:
    - Użycie dziedziczenia: dziedziczy po klasie Car
    - Użycie metod w klasach: dodaje metodę refund()
    - Polimorfizm: obiekty tej klasy mogą być używane jako Car

    Wzorzec projektowy: Strategia (Strategy)
    - SoldCar implementuje strategię dla sprzedanych samochodów
    - Różne zachowanie niż AvailableCar
    """

    def refund(self):
        """
        Zwrot samochodu (anulowanie sprzedaży).

        Zmienia status sprzedaży z powrotem na dostępny.

        Returns:
            float: Zwracana kwota (cena samochodu)
        """
        self.sold = None
        return self.price


class CarFactory:
    """
    Fabryka do tworzenia obiektów samochodów.

    Zastosowane zagadnienia OOP:
    - Użycie dekoratora @staticmethod i @classmethod
    - Klasa zawierająca więcej niż jeden konstruktor (alternatywne sposoby tworzenia)
    - Polimorfizm: zwraca różne typy obiektów ale wszystkie dziedziczą po Car

    Wzorzec projektowy: Fabryka (Factory)
    - Centralizuje logikę tworzenia obiektów
    - Decyduje który typ obiektu utworzyć na podstawie danych
    - Ukrywa szczegóły implementacji przed klientem

    Wzorzec projektowy: Budowniczy (Builder) - częściowo
    - Różne metody tworzenia obiektów (z bazy, z formularza)
    - Każda metoda buduje obiekt w inny sposób
    """

    @staticmethod
    def create_from_row(row):
        """
        Tworzy obiekt samochodu z wiersza bazy danych.

        Użycie @staticmethod - metoda nie wymaga instancji klasy.
        Polimorfizm - zwraca AvailableCar lub SoldCar, ale oba są Car.

        Args:
            row (tuple): Wiersz z bazy danych zawierający dane samochodu

        Returns:
            AvailableCar/SoldCar: Odpowiedni typ samochodu na podstawie statusu
        """
        if row[-1] != 's':
            car = AvailableCar(*row)
        else:
            car = SoldCar(*row)
        return car

    @classmethod
    def create_from_form(cls, form_data):
        """
        Tworzy obiekt samochodu z danych formularza.

        Użycie @classmethod - alternatywny konstruktor.
        Klasa zawierająca więcej niż jeden konstruktor - różne sposoby tworzenia.

        Args:
            form_data (dict): Słownik z danymi z formularza

        Returns:
            Car: Nowy obiekt samochodu
        """
        return Car(None, form_data['body'], form_data['engine'],
                   form_data['drive'], form_data['colour'],
                   form_data['price'], None)


# Przykład użycia super() - rozszerzenie funkcjonalności
class PremiumCar(Car):
    """
    Klasa reprezentująca samochód premium.

    Zastosowane zagadnienia OOP:
    - Użycie dziedziczenia: dziedziczy po Car
    - Pokazanie nadpisywania atrybutów w klasach potomnych: dodaje _warranty
    - Pokazanie nadpisywania metod w klasach potomnych: nadpisuje __init__ i __str__
    - Użycie implementacji z klasy rodzica: super()
    """

    def __init__(self, car_id, body, engine, drive, colour, price, sold, warranty_years=3):
        """
        Konstruktor klasy PremiumCar.

        Użycie super() - wywołuje konstruktor klasy bazowej.
        Pokazanie nadpisywania atrybutów - dodaje warranty_years.

        Args:
            warranty_years (int): Lata gwarancji (domyślnie 3)
        """
        super().__init__(car_id, body, engine, drive, colour, price, sold)
        self._warranty_years = warranty_years

    @property
    def warranty_years(self):
        """Getter dla lat gwarancji."""
        return self._warranty_years

    def __str__(self):
        """
        Nadpisanie metody __str__ z klasy bazowej.

        Pokazanie nadpisywania metod w klasach potomnych.
        Użycie super() - używa implementacji z klasy rodzica i rozszerza ją.

        Returns:
            str: Rozszerzony opis samochodu z informacją o gwarancji
        """
        base_str = super().__str__()
        return f"{base_str} | Warranty: {self._warranty_years} years"