# FishFresh App Theme Documentation

## 🎨 Theme Overview

Tema aplikasi FishFresh dirancang untuk mencerminkan:
- **Kesegaran**: Warna-warna segar dan alami
- **Laut**: Palet warna biru dan aqua yang mengingatkan pada laut
- **Clean**: Design yang bersih dan minimalis
- **Sederhana**: UI yang mudah dipahami dan tidak rumit

## 🌊 Color Palette

### Primary Colors
- **Primary Blue** (`#0277BD`): Warna utama aplikasi, menggambarkan laut yang dalam
- **Light Blue** (`#4FC3F7`): Warna sekunder untuk aksen dan highlight
- **Ocean Deep** (`#01579B`): Warna gelap untuk kontras yang kuat

### Fresh Colors
- **Fresh Mint** (`#4DB6AC`): Warna segar untuk elemen positif
- **Sea Foam** (`#80CBC4`): Warna lembut untuk border dan accent
- **Crystal Water** (`#E0F2F1`): Background transparan seperti air kristal

### Status Colors
- **Fresh Green** (`#2E7D32`): Untuk ikan segar
- **Warning Orange** (`#FF8F00`): Untuk ikan kurang segar  
- **Danger Red** (`#D32F2F`): Untuk ikan tidak segar

### Neutral Colors
- **Pure White** (`#FFFFFF`): Background utama
- **Soft Gray** (`#F5F5F5`): Background sekunder
- **Text Dark** (`#263238`): Teks utama
- **Text Light** (`#546E7A`): Teks sekunder

## 🎯 Design Principles

### 1. Kesegaran (Freshness)
- Menggunakan warna-warna yang mengingatkan pada kesegaran
- Gradasi yang lembut dan natural
- Kontras yang jelas untuk keterbacaan

### 2. Laut (Ocean)
- Dominasi warna biru dalam berbagai nuansa
- Gradient yang meniru gelombang laut
- Transparansi yang mengingatkan pada air

### 3. Clean (Bersih)
- White space yang cukup
- Shadow yang lembut dan minimal
- Border radius yang konsisten (12-20px)
- Layout yang terorganisir dengan baik

### 4. Sederhana (Simple)
- Hierarki visual yang jelas
- Tipografi yang mudah dibaca
- Icon yang intuitif
- Navigasi yang straightforward

## 🎨 Component Styling

### Cards
- Background: Pure White
- Border Radius: 16px
- Shadow: Soft shadow dengan opacity rendah
- Border: Crystal Water untuk accent

### Buttons
- Primary: Ocean blue dengan shadow
- Secondary: Fresh mint
- Text: Ocean blue
- Border Radius: 12px
- Padding yang comfortable

### Text Styles
- Headlines: Bold, dark text
- Body: Medium weight, good line height
- Captions: Light text dengan opacity
- Letter spacing yang optimal

### Status Indicators
- Fresh: Green background dengan icon check
- Warning: Orange background dengan icon warning
- Error: Red background dengan icon error
- Info: Blue background dengan icon info

## 📱 Usage Examples

### Freshness Detection Results
```dart
// Menggunakan helper method dari theme
Color statusColor = AppTheme.getFreshnessColor('segar');
Color backgroundColor = AppTheme.getFreshnessBackgroundColor('segar');
```

### Gradients
```dart
// Ocean gradient untuk header
decoration: BoxDecoration(
  gradient: AppTheme.oceanGradient,
)

// Fresh gradient untuk success states
decoration: BoxDecoration(
  gradient: AppTheme.freshGradient,
)
```

### Shadows
```dart
// Soft shadow untuk cards
boxShadow: AppTheme.cardShadow,

// General soft shadow
boxShadow: AppTheme.softShadow,
```

## 🔧 Implementation

Tema ini diimplementasikan di:
- `lib/config/app_theme.dart` - Definisi tema utama
- `lib/main.dart` - Aplikasi theme ke MaterialApp
- Semua halaman menggunakan theme secara konsisten

### Theme Application
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

## 🎯 Benefits

1. **Konsistensi Visual**: Semua komponen menggunakan palet warna yang sama
2. **Brand Identity**: Mencerminkan identitas aplikasi deteksi kesegaran ikan
3. **User Experience**: Warna yang intuitif untuk status kesegaran
4. **Maintainability**: Mudah diubah dan dipelihara
5. **Accessibility**: Kontras yang cukup untuk keterbacaan

## 🔄 Future Enhancements

- Dark theme variant
- Accessibility improvements
- Custom animations
- Advanced gradients
- Dynamic theming based on user preferences
