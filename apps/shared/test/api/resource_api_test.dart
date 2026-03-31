import 'package:bizrush_shared/api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recording_api_client.dart';

void main() {
  group('ResourceApi', () {
    test('list unwraps resource collections from the standard data envelope',
        () async {
      final api = ResourceApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/customer/addresses');
          expect(request.queryParameters['limit'], '10');
          return <String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'address_id': 'addr-1',
                'customer_id': 'cust-1',
                'label': 'Home',
                'line1': '1 Elm St',
                'line2': null,
                'city': 'Charlotte',
                'state': 'NC',
                'postal_code': '28202',
                'country': 'US',
                'instructions': 'Front desk',
                'is_default': true,
              },
            ],
          };
        }),
      );

      final result = await api.list<ResourceAddress>(
        '/v1/customer/addresses',
        ResourceAddress.fromJson,
        queryParameters: const <String, String>{'limit': '10'},
      );

      expect(result.single.addressId, 'addr-1');
      expect(result.single.isDefault, isTrue);
    });

    test('list preserves resource filters and decodes order status history',
        () async {
      final api = ResourceApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/order-status-history');
          expect(request.queryParameters['order_id'], 'ord-1');
          return <String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'order_status_history_id': 'hist-1',
                'order_id': 'ord-1',
                'status': 'SUBMITTED',
                'status_time': '2026-03-30T12:00:00.000Z',
                'note': 'Order submitted through checkout.',
              },
            ],
          };
        }),
      );

      final result = await api.list<ResourceOrderStatusHistory>(
        '/v1/order-status-history',
        ResourceOrderStatusHistory.fromJson,
        queryParameters: const <String, String>{'order_id': 'ord-1'},
      );

      expect(result.single.orderStatusHistoryId, 'hist-1');
      expect(result.single.status, 'SUBMITTED');
      expect(
        result.single.statusTime,
        DateTime.parse('2026-03-30T12:00:00.000Z'),
      );
    });

    test(
        'get, create, update, and delete use the resource envelope consistently',
        () async {
      final client = RecordingApiClient((request) {
        if (request.method == 'DELETE') {
          return null;
        }

        return <String, Object?>{
          'data': <String, Object?>{
            'ticket_id': 'ticket-1',
            'customer_id': 'cust-1',
            'order_id': 'ord-1',
            'issue_type': 'MISSING_ITEM',
            'message': 'Apple missing',
            'status': 'OPEN',
          },
        };
      });
      final api = ResourceApi(client);

      final fetched = await api.get<ResourceSupportTicket>(
        '/v1/customer/support-tickets/ticket-1',
        ResourceSupportTicket.fromJson,
      );
      final created = await api.create<ResourceSupportTicket>(
        '/v1/customer/support-tickets',
        const <String, Object?>{'issueType': 'MISSING_ITEM'},
        ResourceSupportTicket.fromJson,
      );
      final updated = await api.update<ResourceSupportTicket>(
        '/v1/customer/support-tickets/ticket-1',
        const <String, Object?>{'status': 'RESOLVED'},
        ResourceSupportTicket.fromJson,
      );
      await api.delete('/v1/customer/support-tickets/ticket-1');

      expect(fetched.ticketId, 'ticket-1');
      expect(created.status, 'OPEN');
      expect(updated.orderId, 'ord-1');
      expect(client.requests[0].method, 'GET');
      expect(client.requests[1].method, 'POST');
      expect(client.requests[2].method, 'PATCH');
      expect(client.requests[3].method, 'DELETE');
    });
  });
}
