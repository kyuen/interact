//https://dev.twitter.com/docs/api/1.1
//http://saglamdeniz.com/blog/?p=124
//http://twitter4j.org/en/code-examples.html
//twitter4j handler to interface with twitter api
class TwitterHandler
{
   String cKey, cSecret, aToken, aTokenSecret, id_str;
   ConfigurationBuilder cb;
   Twitter twitter;
   //use tweetCount to send unqiue messages
   int tweetCount = 0;
   boolean twitterDebug = false;
   
   //twitterHandler constructor build with twitter api
   TwitterHandler(String id, String cK, String cS, String aT, String aTS)
   {
     id_str = id;
     cKey = cK;
     cSecret = cS;
     aToken = aT;
     aTokenSecret = aTS;
     
     //initialize twitter configuration
     cb = new ConfigurationBuilder();
     cb.setOAuthConsumerKey(cKey);
     cb.setOAuthConsumerSecret(cSecret);
     cb.setOAuthAccessToken(aToken);
     cb.setOAuthAccessTokenSecret(aTS);
     
     //get status updates, run search queries, find follower information, etc. This Twitter object gets built by something
     //called the TwitterFactory, which needs our configuration information that we set above:
     twitter = new TwitterFactory(cb.build()).getInstance();
     
   }  
   void switchDebug()
   {
     if(twitterDebug)
     {
       twitterDebug = false;
     }
     else
     {
       twitterDebug = true;
     }
   }
   
   //post to another wall
   void sendTweet(String userb, String msg)
   {
     try{
        DirectMessage message = twitter.sendDirectMessage(userb, msg);
        if(twitterDebug)
        {
          println("Sent: " + message.getText() + " to @" + message.getRecipientScreenName());
        }
        tweetCount++;
     }
     catch(TwitterException e)
     {
        println(e);
     }
   }
   
   //post to own wall
   void postTweet(String tweet)
   {
     //update own status, tweet at userb
     /* Allows the authenticating users to unfollow the user specified in the ID parameter.
        Returns the unfollowed user in the requested format when successful.
        Returns a string describing the failure condition when unsuccessful. 
        This method calls http://api.twitter.com/1.1/friendships/destroy/[id].json*/
     try{
       Status status = twitter.updateStatus(tweet); 
       if(twitterDebug)
        {
          println("Successfully updated the status to [" + status.getText() + "].");
        }
       tweetCount++;
     }
     catch(TwitterException e)
     {
       println(e);
     }
   }
   
   boolean following(String usera, String userb)
   {
     try{
       Relationship relation = twitter.showFriendship(usera, userb);
       if(relation.isSourceFollowingTarget())
       {
        if(twitterDebug)
        {
          println("already following");
        }
        return true;
       }
       else
       {
        if(twitterDebug)
        {
          println("not following yet");
        }
        return false;
       }
     }
     catch(TwitterException e)
     {
       println(e);
       return false;
     }
   }
   
   //create friendship, pass user screename
   void createFriendship(String userb)
   {
     //createFriendship(java.lang.String screenName, boolean follow)
     /*Returns the befriended user in the requested format when successful.
     returns a string describing the failure condition when unsuccessful.
     If you are already friends with the user an HTTP 403 will be returned.
     This method calls http://api.twitter.com/1.1/friendships/create/[id].json */
     try{
       //check if user is already following userb
       if(!following(this.id_str,userb))
       {
         twitter.createFriendship(userb, true); 
       }
     }
     catch(TwitterException e)
     {
       println(e);
     }
  }
  
  //destroy user friendship, pass user screenname
  void destroyFriendship(String userb)
  {
     //destroyFriendship(java.lang.String screenName)
     try{
       if(following(this.id_str,userb))
       {
         twitter.destroyFriendship(userb); 
       }
     }
     catch(TwitterException e)
     {
       println(e);
     }     
  }
  
  //returns n queried tweets for string
  List<Status> query(String qString, int maxQ)
  {
    Query query = new Query(qString);
    query.count(maxQ);
    //Try making the query request.
    try {     
         QueryResult result = twitter.search(query);
         if(twitterDebug)
         {
           for (Status status : result.getTweets()) {
              System.out.println("@" + status.getUser().getScreenName() + ":" + status.getText());
           }
         }
         return result.getTweets();

    }
    catch (TwitterException e) {
      println(e);
      return null;
    }
  }
  
  //retrieve User Timeline
  List<Status> retrieveTimeline()
  {
    try {
      List<Status> statuses = twitter.getHomeTimeline();
      if(twitterDebug)
      {
        println("Showing home timeline.");
        for (Status status : statuses) {
           println(status.getUser().getName() + ":" + status.getText());
        }
      }
      return  statuses;
    }
     catch (TwitterException e) {
      println(e);
      return null;
    }
  }
}
