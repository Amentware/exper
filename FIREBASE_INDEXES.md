# Firebase Indexes Setup Guide

To optimize query performance in the Exper app, you need to set up the following composite indexes in your Firebase console:

## Required Indexes

### 1. Transactions Collection
This index is required for efficient date-based filtering of transactions for a specific user:

- **Collection**: `transactions`
- **Fields**:
  - `user_id` (Ascending)
  - `date` (Descending)

### 2. Additional Transactions Index
This index is used to check if a category has any transactions:

- **Collection**: `transactions`
- **Fields**:
  - `user_id` (Ascending)
  - `category_id` (Ascending)

### 3. Budgets Collection
This index is required for filtering budgets by month and year for a specific user:

- **Collection**: `budgets`
- **Fields**:
  - `user_id` (Ascending)
  - `month` (Ascending)
  - `year` (Ascending)

### 4. Categories Collection
This index is recommended for efficiently retrieving categories for a specific user:

- **Collection**: `categories`
- **Fields**:
  - `user_id` (Ascending)
  - `name` (Ascending)

## How to Add Indexes

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. In the left sidebar, navigate to "Firestore Database"
4. Click on the "Indexes" tab
5. Click "Add Index"
6. Select the collection (`transactions`, `budgets`, or `categories`)
7. Add the fields in the order specified above
8. Set the order (Ascending/Descending) as specified
9. Click "Create Index"

Wait for the indexes to be built (this might take a few minutes). Once completed, the status will change to "Enabled."

## Automatic Index Creation

Alternatively, when you run a query that requires an index, Firebase will display an error message with a direct link to create the required index. You can click on that link to automatically set up the index.

## Benefits of Indexes

- **Faster Queries**: Properly indexed fields significantly improve query performance.
- **Reduced Costs**: Efficient queries consume fewer read operations.
- **Better User Experience**: The app feels more responsive due to faster data retrieval.

The app includes fallback mechanisms for cases where indexes aren't available, but for optimal performance, it's recommended to set up all the indexes listed above. 