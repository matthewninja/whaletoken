pragma solidity ^0.4.10;

contract AlternateToken {
    function balancex (address _owner) constant returns (uint256);
    function transfer (address _to, uint256 _value) returns (bool);
}

contract WhaleToken {

    event Transfer (address indexed _from, address indexed _to, uint256 _value);

    event Approval (address indexed _owner, address indexed _spender, uint256 _value);

    address owner = msg.sender;

    bool public crowdsale = true;

    mapping (address => uint256) public balance;
    mapping (address => mapping (address => uint256)) allowance;

    uint256 public tokensIssued = 0;
    uint256 public contributions = 0;
    uint256 public whaleTax = 0;

    string public name = "Whale Token";
    string public symbol = "WTK";
    uint8 public decimals = 18;

    function addr_balance (address _addr) constant returns (uint256) { return balance[_addr]; }
    
    function transfer (address _receiver, uint256 _amount) returns (bool _success) {
        if(msg.data.length < (2 * 32) + 4) { throw; }
        if (balance[msg.sender] >= _amount && balance[_receiver] < balance[_receiver] + _amount) {
            balance[msg.sender] -= _amount;
            balance[_receiver] += _amount;
            Transfer(msg.sender, _receiver, _amount);
            return true;
        } 
        return false;
    }

    function transferFrom (address _sender, address _receiver, uint256 _amount) returns (bool success) {
        if (msg.data.length < (2 * 32) + 4) { throw; }
        if (_amount == 0) return false;
        if (balance[_sender] >= _amount && allowance[_sender][msg.sender] >= _amount && balance[_receiver] < balance[_receiver] + _amount) {
            balance[_sender] -= _amount;
            balance[_receiver] += _amount;
            allowance[_sender][msg.sender] -= _amount;
            Transfer(_sender, _receiver, _amount);
            return true;
        }
        return false;
    }
    
    function approve (address _spender, uint256 _value)returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function getAllowance(address addr, address _spender) constant returns (uint256) { return allowance[addr][_spender]; }

    function startCrowdsale () {
        if (msg.sender != owner) { throw; }
        crowdsale = true;
    }

    function stopCrowdsale () {
        if (msg.sender != owner) { throw; }
        crowdsale = false;
    }

    function withdrawAlternateTokens (address _contract) returns (bool) {
        if (msg.sender != owner) { throw; }
        AlternateToken token = AlternateToken(_contract);
        uint256 amount = token.balancex(address(this));
        return token.transfer(owner, amount);
    }

    function getSales () constant returns (uint256, uint256, bool) {
        return (tokensIssued, contributions, crowdsale);
    }

    function () payable {
        if (!crowdsale) { throw; }
        if (msg.value == 0) { return; }
        uint256 tokens = msg.value * 100 - whaleTax;

        owner.transfer(msg.value);
        contributions += msg.value;

        if (msg.value >= 10 finney) { 
            whaleTax += 100 szabo;
        }

        tokensIssued = tokensIssued + tokens;
        balance[msg.sender] += tokens;

        Transfer(address(this), msg.sender, tokens);
    }
}