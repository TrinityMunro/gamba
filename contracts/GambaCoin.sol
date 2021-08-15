pragma solidity ^0.4.2;

contract GambaCoin {
    string public name = "GambaCoin";
    string public symbol = "GAMBA";
    string public standard = "GambaCoin v0.2";
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
        balanceOf[betAddress] = 32317006071311007300714876688669951960444102669715484032130345427524655138867890893197201411522913463688717960921898019494119559150490921095088152386448283120630877367300996091750197750389652106796057638384067568276792218642619756161838094338476170470581645852036305042887575891541065808607552399123930385521914333389668342420684974786564569494856176035326322058077805659331026192708460314150258592864177116725943603718461857357598351152301645904403697613233287231227125684710820209725157101726931323469678542580656697935045997268352998638215525166389437335543602135433229604645318478604952148193555853611059596230655;
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
