# GetInLine - Complete Lib Folder Structure

```
lib/
├── main.dart
│
├── models/                          (7 files)
│   ├── user_model.dart
│   ├── organization_model.dart
│   ├── professional_model.dart
│   ├── appointment_model.dart
│   ├── transaction_model.dart
│   ├── leave_model.dart
│   └── join_request_model.dart
│
├── services/                        (6 files)
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── sms_service.dart
│   └── email_service.dart
│
├── providers/                       (4 files)
│   ├── auth_provider.dart
│   ├── organization_provider.dart
│   ├── professional_provider.dart
│   └── appointment_provider.dart
│
├── widgets/                         (18 files)
│   ├── appointment_card.dart
│   ├── professional_card.dart
│   ├── organization_card.dart
│   ├── user_card.dart
│   ├── leave_card.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── loading_widget.dart
│   ├── empty_state_widget.dart
│   ├── status_badge.dart
│   ├── qr_code_widget.dart
│   ├── date_time_picker_widget.dart
│   ├── queue_position_widget.dart
│   ├── time_slot_picker.dart
│   ├── payment_widget.dart
│   ├── chart_widget.dart
│   ├── filter_widget.dart
│   └── sort_widget.dart
│
├── utils/                           (12 files)
│   ├── constants.dart
│   ├── helpers.dart
│   ├── app_theme.dart
│   ├── app_router.dart
│   ├── environment_config.dart
│   ├── api_endpoints.dart
│   ├── build_config.dart
│   ├── firebase_options.dart
│   ├── notification_helper.dart
│   ├── permission_helper.dart
│   ├── image_picker_helper.dart
│   └── export_helper.dart
│
└── screens/                         (33 files)
    ├── auth/                        (3 files)
    │   ├── user_login_screen.dart
    │   ├── organization_login_screen.dart
    │   └── create_update_profile_screen.dart
    │
    ├── common/                      (8 files)
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── settings_screen.dart
    │   ├── profile_screen.dart
    │   ├── help_screen.dart
    │   ├── faq_screen.dart
    │   ├── feedback_screen.dart
    │   └── terms_screen.dart
    │
    ├── customer/                    (7 files)
    │   ├── customer_dashboard.dart
    │   ├── search_organization_screen.dart
    │   ├── my_appointments_screen.dart
    │   ├── appointment_detail_screen.dart
    │   ├── notify_me_screen.dart
    │   ├── organization_details_screen.dart
    │   └── professional_details_screen.dart
    │
    └── organization/               (15 files)
        ├── admin_dashboard.dart
        ├── full_create_organization_screen.dart
        ├── join_organization_screen.dart
        ├── join_requests_screen.dart
        ├── joined_users_screen.dart
        ├── notification_screen.dart
        ├── professionals_screen.dart
        ├── create_update_professional_screen.dart
        ├── leaves_screen.dart
        ├── appointment_list_screen.dart
        ├── create_update_appointment_screen.dart
        ├── transaction_list_screen.dart
        ├── qr_display_screen.dart
        ├── analytics_screen.dart
        └── bulk_operations_screen.dart
```

## Summary
| Folder              | Files |
|---------------------|-------|
| lib/ (root)         | 1     |
| models/             | 7     |
| services/           | 6     |
| providers/          | 4     |
| widgets/            | 18    |
| utils/              | 12    |
| screens/auth/       | 3     |
| screens/common/     | 8     |
| screens/customer/   | 7     |
| screens/organization| 15    |
| **TOTAL**           | **81**|
