# Hướng dẫn cấu hình Push Notifications

## Android Configuration

### 1. Permissions trong android/app/src/main/AndroidManifest.xml

Thêm các permissions sau vào file `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Notifications permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application>
        ...
        
        <!-- Notification receiver -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

### 2. Icon cần thiết

Tạo icon thông báo trong `android/app/src/main/res/drawable/`:
- `ic_notification.png` (24x24dp)

## iOS Configuration

### 1. Capabilities trong ios/Runner/Info.plist

Thêm vào `ios/Runner/Info.plist`:

```xml
<dict>
    ...
    <key>UIBackgroundModes</key>
    <array>
        <string>background-processing</string>
    </array>
</dict>
```

## Tính năng Thông báo Tự động

### 1. Thông báo Ngân sách
- **Cảnh báo vượt ngân sách**: Khi chi tiêu vượt ngân sách đã đặt
- **Cảnh báo sắp vượt**: Khi chi tiêu đạt 80% và 90% ngân sách

### 2. Thông báo Mục tiêu  
- **Hoàn thành mục tiêu**: Khi đạt 100% mục tiêu tiết kiệm
- **Milestone**: Khi đạt 25%, 50%, 75% mục tiêu

### 3. Thông báo Giao dịch
- **Chi tiêu lớn**: Khi chi tiêu gấp đôi mức trung bình tháng
- **Tổng kết tháng**: Báo cáo cuối tháng về thu chi

### 4. Thông báo Khuyến khích
- **Streak tiết kiệm**: Khi không chi tiêu trong 3+ ngày liên tiếp

## Cách hoạt động

### Automatic Monitoring
```dart
// Khi thêm transaction mới
await transactionProvider.addTransaction(transaction);
// → Tự động kiểm tra budget status
// → Tự động kiểm tra large expense
// → Tạo thông báo nếu cần

// Khi thêm tiền vào goal
await goalProvider.addMoneyToGoal(goalId, amount);
// → Tự động kiểm tra goal progress  
// → Tạo thông báo milestone/completion
```

### Push Notification Flow
```
User Action → Activity Monitor → Notification Service → Local Push Notification + Database Storage
```

### Data Structure
```json
{
  "title": "Vượt ngân sách: Ăn uống", 
  "message": "Bạn đã chi vượt 200K₫ so với ngân sách 1M₫",
  "type": "budgetAlert",
  "data": "{\"category\": \"Ăn uống\", \"budgetAmount\": 1000000, \"spentAmount\": 1200000}"
}
```

## Test Notifications

Để test thông báo:

1. **Budget Alert**: Tạo budget 100K, thêm expense 150K cho cùng category
2. **Goal Progress**: Tạo goal 1M, thêm tiền 250K (25% milestone)
3. **Goal Complete**: Thêm tiền đến khi >= target amount
4. **Large Expense**: Thêm expense lớn hơn gấp đôi mức trung bình

## Troubleshooting

### Android
- Kiểm tra notifications permission: Settings > Apps > Finance Tracker > Permissions
- Battery optimization: Settings > Battery > Battery optimization > Finance Tracker → Don't optimize

### iOS  
- Settings > Finance Tracker > Notifications → Allow

### Debug
```dart
// Kiểm tra permission
final hasPermission = await NotificationService.hasNotificationPermission();

// Request permission
final granted = await NotificationService.requestNotificationPermission();
```