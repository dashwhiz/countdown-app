import '../app/app_logger.dart';
import '../models/countdown_event.dart';
import 'events_data_source.dart';

/// Remote data source implementation for API backend
///
/// This is a placeholder implementation for Phase 2 when backend is ready.
/// Currently throws UnimplementedError for all methods.
class EventsRemoteDataSource implements EventsDataSource {
  // TODO: Add API client (e.g., Dio, http)
  // final ApiClient _apiClient;

  @override
  Future<List<CountdownEvent>> getAllEvents() async {
    AppLogger.debug('[RemoteDataSource] getAllEvents called');
    // TODO: Implement API call
    // Example: GET /api/v1/events
    // final response = await _apiClient.get('/events');
    // return (response.data as List).map((json) => CountdownEvent.fromJson(json)).toList();
    throw UnimplementedError('Remote data source not yet implemented');
  }

  @override
  Future<CountdownEvent?> getEvent(String id) async {
    AppLogger.debug('[RemoteDataSource] getEvent called: $id');
    // TODO: Implement API call
    // Example: GET /api/v1/events/{id}
    // final response = await _apiClient.get('/events/$id');
    // return CountdownEvent.fromJson(response.data);
    throw UnimplementedError('Remote data source not yet implemented');
  }

  @override
  Future<void> saveEvent(CountdownEvent event) async {
    AppLogger.debug('[RemoteDataSource] saveEvent called: ${event.id}');
    // TODO: Implement API call
    // Example: POST /api/v1/events or PUT /api/v1/events/{id}
    // if (event exists on server) {
    //   await _apiClient.put('/events/${event.id}', data: event.toJson());
    // } else {
    //   await _apiClient.post('/events', data: event.toJson());
    // }
    throw UnimplementedError('Remote data source not yet implemented');
  }

  @override
  Future<void> deleteEvent(String id) async {
    AppLogger.debug('[RemoteDataSource] deleteEvent called: $id');
    // TODO: Implement API call
    // Example: DELETE /api/v1/events/{id}
    // await _apiClient.delete('/events/$id');
    throw UnimplementedError('Remote data source not yet implemented');
  }

  @override
  Future<void> clearAll() async {
    AppLogger.debug('[RemoteDataSource] clearAll called');
    // TODO: Implement if needed (e.g., for logout)
    // This might not be needed for remote - just clear local cache
    throw UnimplementedError('Remote data source not yet implemented');
  }
}
