pragma solidity ^0.4.2;

contract GambaCoin {
    string public name = "GambaCoin";
    string public symbol = "GAMBA";
    string public standard = "GambaCoin v0.1";
    uint256 public totalSupply = 1000000000;
    address public betAddress = 0x7777777777777777777777777777777777777777;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        balanceOf[betAddress] = totalSupply / 2;
    }

    // TODO investigate 499
    function coinFlip() public view returns (bool) {
        uint256 seed =
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp +
                            block.difficulty +
                            ((
                                uint256(
                                    keccak256(abi.encodePacked(block.coinbase))
                                )
                            ) / (now)) +
                            block.gaslimit +
                            ((
                                uint256(keccak256(abi.encodePacked(msg.sender)))
                            ) / (now)) +
                            block.number
                    )
                )
            );

        return (seed - ((seed / 1000) * 1000)) > 499;
    }

    function _gamba(uint256 _value)  public
        returns (bool success){
       
        if (coinFlip()) {
            balanceOf[msg.sender] += _value;
            balanceOf[betAddress] -= _value;
            Transfer(betAddress, msg.sender, _value);
        } else {
            balanceOf[msg.sender] -= _value;
            balanceOf[betAddress] += _value;
           Transfer(msg.sender, betAddress, _value);
        }
        return true;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
       

        if (_to == betAddress) {
            _gamba(_value);
            return true;
        }
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
}
