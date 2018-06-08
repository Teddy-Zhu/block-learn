pragma solidity ^0.4.0;


contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BuffToken is ERC20Interface {
    string public symbol = "Buff Token";
    string public  name = "BUFF";
    uint8 public decimals = 5;
    uint public _totalSupply = 100000000 * 10 ** uint256(decimals);


    function BuffToken(){

    }

    //optional
    //名称
    function name() view returns (string name){

        return name;
    }

    //optional
    //单位
    function symbol() view returns (string symbol){

        return symbol;
    }

    //optional
    //小数位
    function decimals() view returns (uint8 decimals){

        return decimals;
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }


    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }

}
