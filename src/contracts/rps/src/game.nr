use dep::aztec::types::{
    address::{AztecAddress},
    type_serialization::TypeSerializationInterface
};

global GAME_SERIALIZED_LEN: Field = 5;

struct Game {
    challenger: AztecAddress,
    challengee: AztecAddress,
    challengeeThrow: Field,
    challengeeThrowTime: Field,
    settled: Field
}

impl Game {
    pub fn new(challenger: AztecAddress, challengee: AztecAddress) -> Self {
        Game {
            challenger,
            challengee,
            challengeeThrow: 0,
            challengeeThrowTime: 0,
            settled: 0
        }
    }

    pub fn serialize(self) -> [Field; GAME_SERIALIZED_LEN] {
        [self.challenger.address as Field,
        self.challengee.address as Field,
        self.challengeeThrow,
        self.challengeeThrowTime,
        self.settled]
    }
}

fn deserialize(preimage: [Field; GAME_SERIALIZED_LEN]) -> Game {
    Game {
        challenger: AztecAddress::new(preimage[0]),
        challengee: AztecAddress::new(preimage[1]),
        challengeeThrow: preimage[2],
        challengeeThrowTime: preimage[3],
        settled: preimage[4]
    }
}

fn serialize(game: Game) -> [Field; GAME_SERIALIZED_LEN] {
    game.serialize()
}

global GameMethods = TypeSerializationInterface {
    deserialize,
    serialize
};
