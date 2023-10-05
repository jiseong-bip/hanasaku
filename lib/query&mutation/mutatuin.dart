import 'package:graphql_flutter/graphql_flutter.dart';

var signUp = gql('''
        mutation SignUp(\$fbId: String!, \$deviceToken: String!) {
          signUp(fbId: \$fbId, deviceToken: \$deviceToken) {
            ok
            token
            userName
            error
          }
        }
      ''');

var checkUser = gql('''
        mutation CheckUser(\$checkUserId: String!, \$deviceToken: String!) {
  checkUser(id: \$checkUserId, deviceToken: \$deviceToken) {
    ok
    token
    userName
  }
}
      ''');
