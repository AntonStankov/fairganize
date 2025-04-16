import Array "mo:base/Array";
module {
  public type User = {
    name: Text;
    principal: Principal;
  };

  public func createUser(name: Text, principal: Principal) : User {
    { name = name; principal = principal }
  };

  public func findUser(users: [User], principal: Principal) : ?User {
    Array.find<User>(users, func(user) { user.principal == principal });
  };
}
