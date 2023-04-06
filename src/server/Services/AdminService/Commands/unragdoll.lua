return {
    Name = 'UnRagdoll';
    Aliases = {'unragdoll', "unflop", "ragfix"};
    Description = 'Removed ragdoll from a specified user';
    Group = 3;
    Args = {
        {
            Type = 'player';
            Name = 'Player';
            Description = 'Player to un-ragdoll'
        }
    }
}