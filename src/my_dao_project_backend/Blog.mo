import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
  public type BlogPost = {
    id: Nat;
    title: Text;
    content: Text;
    author: Principal;
    timestamp: Time.Time;
    orgId: Nat;
  };
}
