mod game;
mod throw;

contract RPS {
    use dep::std::option::Option;
    use dep::aztec::{
        note::{
            note_header::NoteHeader
        },
        context::{PrivateContext, PublicContext, Context},
        state_vars::{
            map::Map,
            public_state::PublicState,
            immutable_singleton::ImmutableSingleton
        },
        types::{
            type_serialization::field_serialization::{FieldSerializationMethods, FIELD_SERIALIZED_LEN},
            address::{AztecAddress}
        },
        selector::compute_selector
    };
    use dep::easy_private_state::easy_private_state::EasyPrivateUint;

    use crate::{
        game::{Game, GameMethods, GAME_SERIALIZED_LEN},
        throw::{ThrowNote, ThrowNoteMethods, THROW_NOTE_LEN},
    };


    struct Storage {
        // game_id => game data
        games: Map<PublicState<Game, GAME_SERIALIZED_LEN>>,
        // game_id => private (challenger) throw
        privateThrows: Map<ImmutableSingleton<ThrowNote, THROW_NOTE_LEN>>,
        // address => games won
        wins: Map<PublicState<Field, FIELD_SERIALIZED_LEN>>,
        // address => games lost
        losses: Map<PublicState<Field, FIELD_SERIALIZED_LEN>>
    }

    impl Storage {
        fn init(context: Context) -> pub Self {
            Storage {
                games: Map::new(context, 1, |context, slot| {
                    PublicState::new(context, slot, GameMethods)
                }),
                privateThrows: Map::new(context, 2, |context, slot| {
                    ImmutableSingleton::new(context, slot, ThrowNoteMethods)
                }),
                wins: Map::new(context, 3, |context, slot| {
                    PublicState::new(context, slot, FieldSerializationMethods)
                }),
                losses: Map::new(context, 4, |context, slot| {
                    PublicState::new(context, slot, FieldSerializationMethods)
                })
            }
        }
    }

    ////////////////////////////////
    ////// EXTERNAL FUNCTIONS //////
    ////////////////////////////////

    #[aztec(private)]
    fn constructor() {}

    #[aztec(private)]
    fn challenge(challengee: AztecAddress, game_id: Field, first_throw: Field) {
        // 1 = rock, 2 = paper, 3 = scissors
        assert(first_throw as u32 > 0);
        assert(first_throw as u32 < 4);

        // msg.sender == 0 would screw up the validation check below, so check explicitly
        assert(context.msg_sender() != 0);

        let mut note = ThrowNote::new(first_throw, context.msg_sender());
        storage.privateThrows.at(game_id).initialize(&mut note, Option::some(context.msg_sender()));

        let selector = compute_selector("_validateAndAddGame(Field,Field)");
        context.call_public_function(context.this_address(), selector, [challengee.address, game_id]);
    }

    #[aztec(public)]
    fn throw(game_id: Field, throw: Field) {
        let mut game = storage.games.at(game_id).read();

        // if a challengee has been set, only they can throw in response
        // if no challengee is set, anyone can throw and set themselves as challengee
        if (game.challengee.address != 0) {
            assert(game.challengee.address == context.msg_sender());
        } else {
            game.challengee.address = context.msg_sender();
        }

        // the throw can live in public state because challenger throw has already been made
        game.challengeeThrow = throw;
        game.challengeeThrowTime = context.timestamp();
        storage.games.at(game_id).write(game);
    }

    #[aztec(private)]
    fn settle(game_id: Field) {
        let challengerThrow = storage.privateThrows.at(game_id).get_note().choice;
        let game = storage.games.at(game_id).read();
        let challengee = game.challengee.address;
        let challenger = game.challenger.address;

        let selector = compute_selector("_updateLeaderboard(AztecAddress,AztecAddress)");

        if (challengerThrow == 1) {
            if (game.challengeeThrow == 2) {
                context.call_public_function(context.this_address(), selector, [challengee, challenger])
            } else if (game.challengeeThrow == 3) {
                context.call_public_function(context.this_address(), selector, [challenger, challengee])
            } // otherwise it's a tie, no action

        } else if (challengerThrow == 2) {
            if (game.challengeeThrow == 1) {
                context.call_public_function(context.this_address(), selector, [challenger, challengee])
            } else if (game.challengeeThrow == 3) {
                context.call_public_function(context.this_address(), selector, [challengee, challenger])
            } // otherwise it's a tie, no action

        } else if (challengerThrow == 3) {
            if (game.challengeeThrow == 1) {
                context.call_public_function(context.this_address(), selector, [challengee, challenger])
            } else if (game.challengeeThrow == 2) {
                context.call_public_function(context.this_address(), selector, [challenger, challengee])
            } // otherwise it's a tie, no action
        }
    }

    #[aztec(public)]
    fn timeout(game_id: Field) {
        let game = storage.games.at(game_id).read();

        // if 1 day has passed since the challengee threw and challenger hasn't settled, challengee wins
        let timeout = game.challengeeThrowTime + (60 * 60 * 24);
        assert(context.timestamp() as u32 > timeout as u32);

        // update the leaderboard based on the win
        let selector = compute_selector("_updateLeaderboard(AztecAddress,AztecAddress)");
        context.call_public_function(context.this_address(), selector, [game.challengee.address, game.challenger.address])
    }

    ////////////////////////////////
    ////// INTERNAL FUNCTIONS //////
    ////////////////////////////////

    #[aztec(public)]
    internal fn _validateAndAddGame(challengee: AztecAddress, game_id: Field) {
        // confirm that this game id hasn't been used before
        assert(storage.games.at(game_id).read().challenger.address as Field == 0);

        // create the game and put it in public state
        let game = Game::new(AztecAddress::new(context.msg_sender()), challengee);
        storage.games.at(game_id).write(game);
    }

    #[aztec(public)]
    internal fn _updateLeaderboard(winner: AztecAddress, loser: AztecAddress) {
        // update the public wins and losses for the two players
        storage.wins.at(winner.address).write(storage.wins.at(winner.address).read() + 1);
        storage.losses.at(loser.address).write(storage.losses.at(loser.address).read() + 1);
    }
}
