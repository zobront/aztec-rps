mod game;
mod thrownote;

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
        thrownote::{ThrowNote, ThrowNoteMethods, THROW_NOTE_LEN},
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
    fn challengeeThrow(game_id: Field, throw_value: Field) {
        // 1 = rock, 2 = paper, 3 = scissors
        assert(throw_value as u32 > 0);
        assert(throw_value as u32 < 4);

        let mut game = storage.games.at(game_id).read();

        // if a challengee has been set, only they can throw in response
        // if no challengee is set, anyone can throw and set themselves as challengee
        if (game.challengee.address != 0) {
            assert(game.challengee.address == context.msg_sender());
        } else {
            game.challengee.address = context.msg_sender();
        }

        // make sure the throw hasn't happened yet
        assert(game.challengeeThrow == 0);

        // the throw can live in public state because challenger throw has already been made
        game.challengeeThrow = throw_value;
        game.challengeeThrowTime = context.timestamp();
        storage.games.at(game_id).write(game);
    }

    #[aztec(private)]
    fn settle(game_id: Field, outcome: Field) {
        assert(outcome as u32 < 3); // 0 = tie, 1 = win, 2 = lose
        let challengerThrow = storage.privateThrows.at(game_id).get_note().choice;
        let selector = compute_selector("_validateAndUpdateLeaderboard(Field,Field,Field)");
        context.call_public_function(context.this_address(), selector, [game_id, outcome, challengerThrow]);
    }

    #[aztec(public)]
    fn timeout(game_id: Field) {
        let game = storage.games.at(game_id).read();
        assert(!game.settled);

        // if 1 day has passed since the challengee threw and challenger hasn't settled, challengee wins
        let timeout = game.challengeeThrowTime + (60 * 60 * 24);
        assert(timeout as u32 > 0);
        assert(context.timestamp() as u32 > timeout as u32);

        // update the leaderboard based on the win
        storage.wins.at(game.challengee.address).write(storage.wins.at(game.challengee.address).read() + 1);
        storage.losses.at(game.challenger.address).write(storage.losses.at(game.challenger.address).read() + 1);
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
    internal fn _validateAndUpdateLeaderboard(game_id: Field, outcome: Field, challengerThrow: Field) {
        let mut game = storage.games.at(game_id).read();

        // ensure the game hasn't already been settled
        assert(!game.settled);

        let challengee = game.challengee.address;
        let challenger = game.challenger.address;

        // validate the submitted outcome was true based on the throws
        // update the public wins and losses for the two players
        if (outcome == 1) {
            if (challengerThrow == 1) {
                assert(game.challengeeThrow == 3);
            } else {
                assert(challengerThrow == game.challengeeThrow + 1);
            }
            storage.wins.at(challenger).write(storage.wins.at(challenger).read() + 1);
            storage.losses.at(challengee).write(storage.losses.at(challengee).read() + 1);
        } else if (outcome == 2) {
            if (challengerThrow == 3) {
                assert(game.challengeeThrow == 1);
            } else {
                assert(challengerThrow == game.challengeeThrow - 1);
            }
            storage.wins.at(challengee).write(storage.wins.at(challengee).read() + 1);
            storage.losses.at(challenger).write(storage.losses.at(challenger).read() + 1);
        } else {
            assert(challengerThrow == game.challengeeThrow);
        }

        // settle the game so this can't be called again
        game.settled = true;
        storage.games.at(game_id).write(game);
    }
}
