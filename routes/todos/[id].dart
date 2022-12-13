import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../database/database_connectivity.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final requestType = context.request.method.value;

  final dbConnectivity = DatabaseConnectivity();
  final db = await dbConnectivity.connectToDatabase();
  final collection = db.collection('todos');

  final userId = context.request.headers['userId'] ?? '';

  switch (requestType) {
    case 'GET':
      {
        final todo = await collection.modernFindOne(
          filter: {'_id': ObjectId.parse(id),
                  'createdBy' : ObjectId.parse(userId)},
        );
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: todo);
      }

    case 'DELETE':
      {
        await collection.deleteOne({'_id': ObjectId.parse(id),
                                    'createdBy' : ObjectId.parse(userId)});
        dbConnectivity.closeDatabaseConnection(db);
        return Response(statusCode: 204);
      }

    case 'PATCH':
      {
        final data = await context.request.json() as Map<String, dynamic>;
        // ignore: cascade_invocations
        data.forEach((key, value) async {
          await collection.updateOne(
            where.eq('_id', ObjectId.parse(id)),
            modify.set(key, value),
          );
        });
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: data);
      }

    default:
      {
        return Response(body: 'Invalid Http Method', statusCode: 403);
      }
  }
}
