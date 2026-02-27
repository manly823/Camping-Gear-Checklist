# Camping Gear Checklist

Smart packing companion for outdoor trips with hexagonal dashboard, weight analysis, food planner, and knot reference guide.

## Features

- **Hexagon Tile Dashboard** — category-based navigation with custom HexagonShape tiles and MountainRange decorative header
- **Smart Checklists** — gear lists generated per trip type (mountain/forest/lake/winter/desert/beach) with `.searchable` and category filter chips
- **Weight Analysis** — pie chart breakdown by category (SectorMark), bar comparison, ultralight/lightweight/traditional benchmarks
- **Food Planner** — calorie calculator by group × days, daily meal breakdown chart, water requirements with bar chart
- **Knot Guide** — 8 essential knots with step-by-step instructions, expandable cards with spring animation, difficulty badges
- **Trip Log** — journal of past trips with type, location, duration, group size
- **Onboarding** — 5 pages including trip setup form with type picker, duration, group size, experience level
- **Data Export** — ShareLink for JSON export of all trip data and gear lists

## Tech Stack

- SwiftUI (iOS 17+), Swift Charts (SectorMark, BarMark)
- Custom Shapes: HexagonShape, MountainRange
- .searchable, ShareLink, Haptics, MVVM, UserDefaults

## Build

```bash
xcodebuild -project CampingGear.xcodeproj -scheme CampingGear \
  -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO build
```
