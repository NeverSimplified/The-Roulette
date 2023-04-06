return {
    Name = 'unragdoll';
    Aliases = {'unragdoll', "unflop", "ragfix"};
    Description = 'Removed ragdoll from a specified user(s)';
    Group = 3;
    Args = {
        {
            Type = 'players';
            Name = 'Player(s)';
            Description = 'Player(s) to un-ragdoll'
        }
    }
}