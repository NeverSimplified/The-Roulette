return {
    Name = 'ragdoll';
    Aliases = {'ragd', "flop"};
    Description = 'Ragdolls the provided user(s)';
    Group = 3;
    Args = {
        {
            Type = 'players';
            Name = 'Player(s)';
            Description = 'Player(s) to ragdoll'
        }
    }
}