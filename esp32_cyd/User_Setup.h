// Plik konfiguracyjny biblioteki TFT_eSPI dla ESP32 Cheap Yellow Display (CYD)
// Model: ESP32-2432S028R (2.8 cala 320x240 ILI9341)
// 
// Skopiuj zawartość tego pliku lub zastąp plik w folderze:
// Dokumenty/Arduino/libraries/TFT_eSPI/User_Setup.h

#define USER_SETUP_INFO "User_Setup_CYD_ESP32_2432S028R"

// Wybór sterownika wyświetlacza
#define ILI9341_2_DRIVER

// Piny magistrali SPI wyświetlacza
#define TFT_MISO 12
#define TFT_MOSI 13
#define TFT_SCLK 14
#define TFT_CS   15
#define TFT_DC    2
#define TFT_RST  -1

// Podświetlenie ekranu (Backlight)
#define TFT_BL   21
#define TFT_BACKLIGHT_ON HIGH

// Odwrócenie kolorów dla matrycy CYD (likwiduje efekt negatywu / wyblakłego tła)
#define TFT_INVERSION_ON
#define USE_HSPI_PORT

// Czcionki
#define LOAD_GLCD
#define LOAD_FONT2
#define LOAD_FONT4
#define LOAD_FONT6
#define LOAD_FONT7
#define LOAD_FONT8
#define LOAD_GFXFF
#define SMOOTH_FONT

// Częstotliwość SPI (40 MHz dla płynnej animacji)
#define SPI_FREQUENCY  40000000
#define SPI_READ_FREQUENCY  20000000
