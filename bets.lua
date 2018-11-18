type State = 'GAME' | 'CLOSED' 

type Storage = { 
  state: string,
  bets: Map<table>,
  amount: number,
  winner: string,
  owner: string
}

var M = Contract<Storage>()

function M:init()
  self.storage.state = 'GAME'
  self.storage.bets = {}
  self.storage.bets['magnus'] = {}
  self.storage.bets['caruana'] = {}
  self.storage.amount = 0
  self.storage.winner = nil
  self.storage.owner = caller_address
end

offline function M:state(_: string)
  return self.storage.state
end

offline function M:owner(_: string)
  return self.storage.owner
end

function M:setState(newState: string)
  if caller_address == self.storage.owner then
    self.storage.state = newState
  end
end

let function betCommon(competing: string, amount: number)
  local bet = {}
  
  bet[0] = caller_address
  bet[1] = amount
  self.storage.amount = self.storage.amount + amount

  table.insert(self.storage.bets[competing], bet)
end

function M:betOnMagnus(amount: number)
  betCommon('magnus', amount)
end

function M:betOnCaruana(amount: number)
  betCommon('caruana', amount)
end

function M:scatterWinnings()
  if self.storage.state == 'CLOSED' then
    local winners = self.storage.bets[self.storage.winner]

    for index = 1, #winners do
      local amount = winners[index][1]
      local address = winners[index][0]

      transfer_from_contract_to_address(
        caller_address,
        'CHESS',
        (self.storage.amount / amount) * 100
      )
    end
  end
end

return M
