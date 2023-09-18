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
          likeCount
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

  }
}
    """);

final commentContentQuery = gql("""
      query Query(\$contentId: Int!) {
  viewContent(contentId: \$contentId) {
    comments {
      id
      comment
      createDate
      user {
        id
        userName
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
    comments {
      isLiked
      comment
      createDate
      id
      likes{
        user{
          id
        }
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
    images {
      url
    }
    createDate
    content
    isLiked
    likeCount
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
          likeCount
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
              likeCount
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
        categoryId
        title
        likeCount
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

final myInfoQuery = gql("""
      query Query {
  me {
    id
    categories {
      type
      id
    }
    userName
  }
}
    """);

final getCategoryQuery = gql("""
      query ViewCategories {
        viewCategories {
          id
          isSelected
          name
          topColor
          bottomColor
          postCount
          userCount
        }
      }
    """);

final contentQuery = gql("""
query ViewContent(\$contentId: Int!) {
  viewContent(contentId: \$contentId) {
    comments {
      comment
      createDate
      user {
        userName
        id
      }
      id
    }
    createDate
    isLiked
    likeCount
    title
    user {
      id
      userName
    }
    viewCount
    key
  }
}""");

final viewContansQuery = gql("""query ViewContents {
  viewContents {
    title
    key
    id
  }
}""");

final getMyInfoQuery = gql("""
      query Query {
  me {
    medals {
      level
      name
    }
  }
}
    """);
