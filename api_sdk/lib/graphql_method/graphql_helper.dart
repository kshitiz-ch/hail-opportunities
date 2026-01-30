import 'dart:async';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:gql/language.dart';
import 'package:graphql/client.dart';

class GraphQLHelper {
  final GraphQLClient client;

  GraphQLHelper(this.client);

  static final StreamController<OperationException> _errorStreamController =
      StreamController<OperationException>.broadcast();

  static Stream<OperationException> get graphQLErrorStream =>
      _errorStreamController.stream;

  Future<QueryResult<TParsed>> query<TParsed>({
    required String queryName,
    required String queryString,
    Map<String, dynamic> variables = const {},
    bool enableRetry = true,
  }) async {
    final requestPayloadSize = queryString.length + variables.toString().length;

    LogUtil.printLog(variables.toString(), tag: '$queryName variables');

    final WatchQueryOptions<TParsed> _options = WatchQueryOptions(
      document: parseString(queryString),
      variables: variables,
      pollInterval: Duration(seconds: 4),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final response = await queryGraphQlWithRetry(
      queryOptions: _options,
      enableRetry: enableRetry,
      queryName: queryName,
      requestPayloadSize: requestPayloadSize,
    );

    if (response.hasException) {
      LogUtil.printLog(response.toString(), tag: '$queryName response');
      if (response.exception != null) {
        _errorStreamController.add(response.exception!);
      }
    }

    return response;
  }

  Future<QueryResult<TParsed>> mutate<TParsed>({
    required String mutationName,
    required String mutationString,
    Map<String, dynamic> variables = const {},
  }) async {
    final requestPayloadSize =
        mutationString.length + variables.toString().length;

    LogUtil.printLog(variables.toString(), tag: '$mutationName variables');

    final MutationOptions<TParsed> _options = MutationOptions(
      document: parseString(
        mutationString,
      ),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final url = '${ApiConstants().graphqlUrl}mutate/$mutationName';
    final metric =
        await startFirebasePerfromance(url: url, method: HttpMethod.Post);

    QueryResult<TParsed> response = await client.mutate(_options);

    stopFirebasePerfromance(
      httpResponseCode: response.hasException ? 400 : 200,
      metric: metric,
      requestPayloadSize: requestPayloadSize,
      responsePayloadSize: response.data.toString().length,
    );

    if (response.hasException) {
      LogUtil.printLog(response.toString(), tag: '$mutationName response');
      if (response.exception != null) {
        _errorStreamController.add(response.exception!);
      }
    }

    return response;
  }

  Future<HttpMetric?> startFirebasePerfromance(
      {required String url, required HttpMethod method}) async {
    try {
      // start firebase app performance
      final metric = FirebasePerformance.instance.newHttpMetric(
        url,
        method,
      );
      await metric.start();
      return metric;
    } catch (error) {
      LogUtil.printLog('startFirebasePerfromance ==> ${error.toString()}');
      return null;
    }
  }

  void stopFirebasePerfromance({
    required HttpMetric? metric,
    required int httpResponseCode,
    required int requestPayloadSize,
    required int responsePayloadSize,
  }) {
    try {
      // log performance data
      metric?.httpResponseCode = httpResponseCode;
      metric?.requestPayloadSize = requestPayloadSize;
      metric?.responsePayloadSize = responsePayloadSize;
      metric?.stop();
    } catch (error) {
      LogUtil.printLog('stopFirebasePerfromance ==> ${error.toString()}');
    }
  }

  Future<QueryResult<TParsed>> queryGraphQlWithRetry<TParsed>({
    required WatchQueryOptions<TParsed> queryOptions,
    bool enableRetry = true,
    required int requestPayloadSize,
    required String queryName,
  }) async {
    late QueryResult<TParsed> response;
    int retryCount = enableRetry ? 3 : 0;
    do {
      // firebase performance start
      final url = '${ApiConstants().graphqlUrl}query/$queryName';
      final metric =
          await startFirebasePerfromance(url: url, method: HttpMethod.Get);

      response = await client.query(queryOptions);

      // firebase performance stop
      stopFirebasePerfromance(
        httpResponseCode: response.hasException ? 400 : 200,
        metric: metric,
        requestPayloadSize: requestPayloadSize,
        responsePayloadSize: response.data.toString().length,
      );

      retryCount--;
    } while (retryCount > 0 && response.hasException);

    return response;
  }
}
