reset;
#--------------------------------------------------------------------------------
# Zbiory
#--------------------------------------------------------------------------------
# Zbiór produkowanych produktów
set PRODUCTS;
# Zbiór dostępnych narzędzi
set TOOLS;
# Zbiór miesięcy, dla których jest przeprowadzana analiza
set MONTHS ordered;

#-------------------------------------------------------------------------------
# Parametry
#-------------------------------------------------------------------------------

# Liczba każdego z narzędzi
param toolCount { TOOLS } >= 1;
# Marża na każdy z produktów [pln/szt]
param expectedProfitPerUnit { PRODUCTS } >= 0;
# Czas pracy narzędzia t podczas produkcji produktu p
param toolTimePerUnit {TOOLS , PRODUCTS } >= 0;
# Ograniczenie rynkowe produktu p w miesiącu m
param salesMarketLimit {MONTHS , PRODUCTS} >= 0;
# Limit pojemności magazunu na produt p
param storageLimit { PRODUCTS } >= 0;
# Koszt magazynowania jednego produktu [pln]
param storageUnitCost >= 0;
# Wymagana ilość zapasu produktów pod koniec 3 miesiąca
param storageRequirInThirdM >=  0; 
# Dni w miesiącu
param daysPerMonth >= 0;
# Liczba zmian wciągu dnia 
param shiftsPerDay >= 0;
# Czas trwania zmiany
param hoursPerShift >= 0;
# Robotogodziny w miesiącu
param workHoursPerMonth = daysPerMonth * shiftsPerDay * hoursPerShift ;
# Dostępny czas pracy narzędzia t w miesiącu m
param availableToolTime {t in TOOLS } = toolCount [t]* workHoursPerMonth;


#----------------------------------------------------------------------------
# Zmienne
#----------------------------------------------------------------------------

# Liczba wyprodukowanych produktów p w miesiącu m
var produced {PRODUCTS, MONTHS } >= 0 integer ;
# Liczba sprzedanych produktów p w miesiącu m
var sold {PRODUCTS, MONTHS } >= 0 integer ;
# Liczba dostępnyc do sprzedaży produktów p w miesiącu m 
var availableProducts {p in PRODUCTS, m in MONTHS} integer >=0;
# Liczba produktów p zmagazynowanych w miesiącu m
var stored {p in PRODUCTS, m in MONTHS} integer >= 0;
# Całkowita liczba sprzedanych produktów p
var totalSold {p in PRODUCTS } = sum {m in MONTHS } sold [p, m];
# Koszt magazynowania wszystkich produktów w miesiącu m
var monthlyStorageCost {m in MONTHS} = (sum {p in PRODUCTS} stored[p, m])*storageUnitCost;
# Całkowity koszt magazynowania produktów
var totalCostStorege = sum {m in MONTHS} monthlyStorageCost[m];
# Czas pracy narzędzia t w miesiącu m
var monthlyTimeWorkTool {t in TOOLS, m in MONTHS} = sum {p in PRODUCTS} produced[p,m]*toolTimePerUnit[t,p];
# Zysk ze sprzedaży - Przychody
var expectedSalesProfit = sum {p in PRODUCTS} totalSold[p]*expectedProfitPerUnit[p];
# Dochody
var profit = expectedSalesProfit - totalCostStorege;
# Czas trwania poszczególych faz obróbki w miesiącu magazunu
var prodProcessingTime {t in TOOLS, m in MONTHS} = monthlyTimeWorkTool[t, m] / toolCount[t];
# Czas pracy przedsiębiorstwa w danym miesiącu m
var factoryWorkTime {m in MONTHS} >= 0;
# Całkowity czas pracy przedsiębiorstwa w przeciągu trzech miesięcy 
var complateFactoryWorkTime = sum {m in MONTHS} factoryWorkTime[m];


# --------------------------------------------------------------------------
# Ograniczenia
#---------------------------------------------------------------------------



# Ograniczenie magazynowe na sprzedaż produktów
subject to SalesLimit {p in PRODUCTS, m in MONTHS}:
				sold[p,m] <= availableProducts[p,m];

# Ograniczenie pojemności magazynowej
subject to StorageLimit {m in MONTHS, p in PRODUCTS}:
				stored[p,m] <= storageLimit[p];

# Ograniczenie rynkowe na sprzedaż produktów
subject to SalesMarketLimit {m in MONTHS, p in PRODUCTS}: 
				sold[p,m] <= salesMarketLimit[m,p];

# Ograniczenie czasu pracy narzędzi w miesiącu
subject to ToolWorkTime {m in MONTHS, t in TOOLS}:
				monthlyTimeWorkTool[t,m] <= availableToolTime[t];


#Wymaganie zgromadzenia odpowiedniej ilości sztuk każdego produktu p na koniec trzeciego miesiąca
subject to StoredRequirement {p in PRODUCTS}:
                stored[p, last(MONTHS)] = storageRequirInThirdM;

# Liczba dostępnych produktów w pierwszym miesiącu
subject to firstMounthAvailableProducts {p in PRODUCTS}: 
				availableProducts[p,first(MONTHS)] = produced[p, first(MONTHS)];
# Liczba dostępnych produktów po pierwszym miesiacu
subject to anotherMounthAvailableProducts { p in PRODUCTS, m in MONTHS: m!= first(MONTHS)}: 
				availableProducts[p,m] = produced[p, m] + stored[p,prev(m)];

# Liczba przechowywanych przedmiotów
subject to Stored {p in PRODUCTS, m in MONTHS}:
		stored[p,m] <= (availableProducts[p,m]-sold[p,m]);

# Czas produkcji maksyamlana wartość z prodProcessingTime
subject to FactoryWorkTime {m in MONTHS, t in TOOLS}:
        factoryWorkTime[m] >= prodProcessingTime[t,m];

