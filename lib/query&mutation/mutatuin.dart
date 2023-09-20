import 'package:graphql_flutter/graphql_flutter.dart';

var signUp = gql('''
        mutation SignUp(\$fbId: String!) {
          signUp(fbId: \$fbId) {
            ok
            token
            userName
            error
          }
        }
      ''');

var checkUser = gql('''
        mutation CheckUser(\$checkUserId: String!) {
  checkUser(id: \$checkUserId) {
    ok
    token
    userName
  }
}
      ''');
