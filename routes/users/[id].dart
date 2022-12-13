import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../database/database_connectivity.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final requestType = context.request.method.value;

  final dbConnectivity = DatabaseConnectivity();
  final db = await dbConnectivity.connectToDatabase();
  final collection = db.collection('users');
  final todoCollection = db.collection('todos');
  switch (requestType) {
    case 'GET':
      {
        final data = await collection.modernFindOne(
          filter: {'_id': ObjectId.parse(id)},
        );
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: data);
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

    case 'DELETE':
      {
        await todoCollection.deleteMany({'createdBy': ObjectId.parse(id)});
        await collection.deleteOne({'_id': ObjectId.parse(id)});
        dbConnectivity.closeDatabaseConnection(db);
        return Response(statusCode: 204);
      }

    default:
      {
        return Response(body: 'Invalid Http Method', statusCode: 403);
      }
  }
}
