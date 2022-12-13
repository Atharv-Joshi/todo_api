import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../database/database_connectivity.dart';

Future<Response> onRequest(RequestContext context) async {
  final requestType = context.request.method.value;
  final dbConnectivity = DatabaseConnectivity();
  final db = await dbConnectivity.connectToDatabase();
  final collection = db.collection('todos');
  final userId = context.request.headers['userId'] ?? '';
  switch (requestType) {
    case 'GET':
      {
        // ignore: omit_local_variable_types
        Map<String, dynamic> query = {};
        if (context.request.uri.hasQuery) {
          query = context.request.uri.queryParameters;
        }
        query['createdBy'] = ObjectId.parse(userId);
        final todolist = await collection.modernFind(filter: query).toList();
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: todolist);
      }
    case 'POST':
      {
        if (userId == '') return Response(statusCode: 500, body: 'Internal Server Error');
        final data = await context.request.json() as Map<String, dynamic>;
        data['createdBy'] = ObjectId.parse(userId);
        await collection.insertOne(data);
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: data, statusCode: 201);
      }

    default:
      {
        return Response(body: 'Invalid Http Method', statusCode: 403);
      }
  }
}
