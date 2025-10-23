# Contact-Based User Invitation Implementation

## Completed Tasks
- [x] Added phone field to UserEntity and UserModel
- [x] Updated sign-up flow to include phone number field with validation
- [x] Modified auth events, usecases, repositories, and datasources to handle phone
- [x] Added permission_handler and cloud_firestore dependencies
- [x] Created ContactMatch entity with status enum
- [x] Created ContactRepository and ContactRemoteDataSource
- [x] Created ContactRepositoryImpl with phone number matching logic
- [x] Updated ContactBloc to handle contact matching
- [x] Updated ContactSelectionSheet to display contact status and matching
- [x] Updated dependency injection container

## Remaining Tasks
- [ ] Test the contact permission handling and contact fetching
- [ ] Test the phone number matching against existing users
- [ ] Implement invite flow for contacts who need invitation
- [ ] Update GroupMember entity to include user status (existing vs invited)
- [ ] Handle adding existing users vs invited users to groups differently
- [ ] Add proper error handling for permission denied scenarios
- [ ] Test the complete flow from contact selection to group creation
- [ ] Add loading states and better UX for contact matching process
- [ ] Implement caching for contact matching results to improve performance
- [ ] Add search/filter functionality in contact selection sheet
- [ ] Handle edge cases like duplicate phone numbers, invalid phone formats
- [ ] Add analytics/logging for contact invitation usage

## Potential Issues to Address
- Permission handling on different platforms (iOS vs Android)
- Phone number format normalization for matching
- Privacy concerns with storing phone numbers
- Performance with large contact lists
- Offline handling when checking user existence
- Rate limiting for backend phone number checks

## Testing Checklist
- [ ] Contact permission request works correctly
- [ ] Contact fetching displays properly with status indicators
- [ ] Phone number matching works for existing users
- [ ] Invite status shows correctly for non-users
- [ ] Group creation with mixed user types (existing + invited)
- [ ] Error handling for permission denied
- [ ] Error handling for network issues during matching
- [ ] UI responsiveness with large contact lists
