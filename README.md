# Hamsterdam #

Immutable Struct-like record structures based on Hamster's immutable Hashes.  Convenient methods for updating record structures and returning new immutable instances.

# Example #

    Person = Hamsterdam::Struct.define(:name, :address, :age)
    david = Person.new(name: "David", age: true, address: "Coopersville")
    david1 = david.set_address("East Grand Rapids")
    david2 = david.merge(name: "Crosby", age: "increased")
    
