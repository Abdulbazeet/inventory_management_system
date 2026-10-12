# Inventory Management System

A maintainable Dart console application for managing products, categories,
stock levels, low-stock alerts, and inventory value.

## Features

- Add, remove, and update products
- Increase and decrease stock with validation
- Search by product ID or name
- Filter by category
- List all products and low-stock products
- Calculate total inventory value
- Persist data asynchronously in `data/inventory.json`
- Publish stock changes and low-stock alerts with Dart streams
- Generic in-memory `DataStore<T>`

## Concepts

The project demonstrates object-oriented design, interfaces, generics, async
and await, streams, JSON serialization, custom exceptions, and automated tests.

## Structure

```text
bin/inventory_management_system.dart
lib/models/                  Product and Category
lib/repositories/            Generic store and repository interface
lib/services/                Inventory, storage, and stock monitoring
lib/cli/                     Menu-driven terminal interaction
lib/exceptions/              Domain exception
lib/utils/                   Validated terminal input helpers
data/inventory.json           Persistent inventory data
test/                         Model, service, and storage tests
```

## Prerequisites

- Dart SDK 3.13.4 or newer within the declared SDK range

## Setup and execution

```bash
dart pub get
dart format .
dart analyze
dart test
dart run
```

The application loads `data/inventory.json` when it starts and saves after each
successful change. A missing file is created automatically with an empty JSON
array. Stock-changing operations publish events to `StockMonitorService`; the
CLI subscribes before showing the menu so low-stock alerts are displayed while
the application is running.

## Example usage

Choose `1` and enter values such as:

```text
Product id: p1
Name: Keyboard
Description: Mechanical keyboard
Category id: electronics
Price: 49.99
Quantity: 10
Low-stock threshold: 2
```

Then choose `5` to decrease stock, `6` to search, `9` to see low-stock items,
or `10` to calculate the total inventory value. Choose `0` to exit.
# inventory_management_system
