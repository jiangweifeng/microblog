import Principal "mo:base/Principal";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Time "mo:base/Time";

actor {
    public type Message = {
        text: Text;
        time: Time.Time;
    };
    public type MicroBlog = actor {
        follow : shared (Principal) -> async(); 
        follows : shared query () -> async [Principal];
        post : shared (Text) -> async ();
        posts : shared query (Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async[Message];
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow (id: Principal) : async(){
        followed :=List.push(id, followed);
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post (text: Text) : async(){
        //make sure the caller is anonymous, for testing purpose only
        assert(Principal.toText(msg.caller)=="2vxsx-fae"); 
        messages := List.push({text= text; time = Time.now()}, messages);
    };

    public shared query func posts(since: Time.Time): async [Message]{
        List.toArray(List.filter<Message>(messages, func(msg: Message): Bool {msg.time >= since}))
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all : List.List<Message> = List.nil();
        for ( id in Iter.fromList(followed)){
            let canister: MicroBlog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)){
                all :=List.push(msg,all);
            };
        };
        List.toArray(all)
    };

};
