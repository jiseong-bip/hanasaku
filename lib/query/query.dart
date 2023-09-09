import 'package:graphql_flutter/graphql_flutter.dart';

final viewPostsQuery = gql("""
      query ViewPosts(\$categoryId: Int!, \$take: Int!, \$offset: Int!) {
        viewPosts(categoryId: \$categoryId, take: \$take, offset: \$offset) {
          id
          title
          createDate
          content
          images {
            url
          }
          user {
            id
            userName
          }
          likes {
            user {
              userName
            }
          }
          isLiked
          comments {
            user {
              id
              userName
            }
          }
        }
      }
    """);

final commentPostQuery = gql("""
      query ViewPost(\$viewPostPostId2: Int!) {
  viewPost(postId: \$viewPostPostId2) {
    comments {
      isLiked
      comment
      createDate
      id
      likes {
        userId
      }
      user {
        id
        userName
      }
      recomments {
        user {
          userName
        }
        comment
        createDate
      }
    }
  }
}
    """);

final postQuery = gql("""
      query ViewPost(\$postId: Int!) {
  viewPost(postId: \$postId) {
    user {
      id
      userName
    }
    comments{
      id
    }
    images {
      url
    }
    createDate
    content
    isLiked
    likes {
      user {
        userName
      }
    }
    title
    id
  }
}
    """);

final chatRoomsQuery = gql("""
      query ViewChatRooms {
  viewChatRooms {
    isReadRoom
    user {
      userName
    }
    updateAt
    lastMessage {
      user {
        userName
      }
      message
      isRead
      createDate
    }
    id
  }
}
    """);

final chatQuery = gql("""
      query ViewChatRoom(\$viewChatRoomRoomId2: Int!) {
  viewChatRoom(roomId: \$viewChatRoomRoomId2) {
    messages {
      id
      message
      user {
        id
        userName
      }
      createDate
    }
  }
}
    """);

final myPostQuery = gql("""
      query Me {
        me {
          posts {
            id
            title
          likes {
            id
          }
          comments {
            id
          }
          categoryId
        }
      }
    }
    """);

final likedPostQuery = gql("""
      query Me {
        me {
          postLikes {
            post {
              title
              id
              likes {
                userId
              }
            categoryId
            comments {
              id
            }
          }
        }
      }
    }
    """);

final myCommentQuery = gql("""
      query Me {
        me {
    postComments {
      comment
      createDate
      post {
        id
        title
        likes {
          userId
        }
        comments {
          userId
        }
        images {
          url
        }
      }
    }
  }
}
    """);
