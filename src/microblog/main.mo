import Principal "mo:base/Principal";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Time "mo:base/Time";

actor {

    public type Message = {
        content: Text;
        time: Time.Time;
        author: Text;
    };

    public type MicroBlog = actor {
        follow : shared (Principal) -> async(); 
        follows : shared query () -> async [Principal];
        post : shared (Text) -> async ();
        posts : shared query () -> async [Message];
        timeline: shared () -> async[Message];
        get_name: shared () -> async ?Text;
        set_name: shared (Text) -> async ();
    };

    stable var followed : List.List<Principal> = List.nil();
    stable var name : Text = "";

    public shared func get_name(): async ?Text{
        ?name;
    };

    public shared (msg) func set_name(n: Text): async() {
        assert(Principal.toText(msg.caller) == "q7og2-3h7sd-fzbfx-ysfeh-ywxeo-c4y6y-3nrqc-rtarm-tie7e-lpxa6-dqe");
        name := n;
    };

    public shared (msg) func follow (id: Principal) : async(){
        assert(Principal.toText(msg.caller) == "q7og2-3h7sd-fzbfx-ysfeh-ywxeo-c4y6y-3nrqc-rtarm-tie7e-lpxa6-dqe");
        followed :=List.push(id, followed);
    };

    public shared (msg) func clear_follows () : async(){
        assert(Principal.toText(msg.caller) == "q7og2-3h7sd-fzbfx-ysfeh-ywxeo-c4y6y-3nrqc-rtarm-tie7e-lpxa6-dqe");
        followed :=List.nil()
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post (text: Text, password: Text) : async(){
        //make sure the caller is anonymous, for testing purpose only
        // assert(Principal.toText(msg.caller)=="2vxsx-fae"); 
        assert(password == "icp_training_Task_passw0rd");
        messages := List.push({content= text; time = Time.now(); author = name}, messages);
    };

    public shared query func posts(): async [Message]{
        List.toArray(messages)
        // List.toArray(List.filter<Message>(messages, func(msg: Message): Bool {msg.time >= since}))
    };

    public shared func timeline(): async [Message] {
        var all : List.List<Message> = List.nil();
        for ( id in Iter.fromList(followed)){
            let canister: MicroBlog = actor(Principal.toText(id));
            let msgs = await canister.posts();
            for (msg in Iter.fromArray(msgs)){
                all :=List.push(msg,all);
            };
        };
        List.toArray(all)
    };

};
