import 'package:graphql_flutter/graphql_flutter.dart';

var signUp = gql('''
        mutation SignUp(\$userName: String!, \$age: Int!, \$sex: String!, \$fbId: String!) {
          signUp(userName: \$userName, age: \$age, sex: \$sex, fbId: \$fbId) {
            ok
            token
            error
          }
        }
      ''');

var checkUser = gql('''
        mutation CheckUser(\$checkUserId: String!) {
  checkUser(id: \$checkUserId) {
    ok
    token
  }
}
      ''');
