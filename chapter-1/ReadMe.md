# 区块链学习教程(1):如何基于以太坊创建一个ERC20 Token


## 准备
* 了解区块链的基本概念和原理
* 了解以太坊
* 了解以太坊的编程语言solidity (这边推荐一个有趣味的学习以太坊的教程: [Link](https://cryptozombies.io/zh/course))

## 初识ERC20
ERC20是以太坊Token的一个标准,它定义一些作为Token合约必要的接口.
ERC20接口参考文档: [Link](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)


首先我们需要给出erc20的接口合约
代码如下:

```solidity
contract ERC20Interface {

    // 提供的erc20 token 的数量
    function totalSupply() public constant returns (uint);

    // 查询当前地址拥有 token 数量
    function balanceOf(address tokenOwner) public constant returns (uint balance);

    // 查询spender 允许从 tokenOwner 使用的token数量
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    // 合约方法执行的地址发送给 to 地址的token 数量
    function trandesfer(address to, uint tokens) public returns (bool success);

    // 合约执行方法的地址授权给spender 可用的token 数量
    function approve(address spender, uint tokens) public returns (bool success);
    // 从from 地址转 指定数量的token 到 to 地址,仅仅当to地址被from地址授权之后才能执行成功
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    //发生转账触发的事件
    event Transfer(address indexed from, address indexed to, uint tokens);
    //发生授权触发的事件
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
```

接口有了下面我们要定义我们自己的Token的合约

代码如下:

```
contract BuffToken is ERC20Interface{
    function BuffToken(){

    }
}

```

## 完善合约

上一步我们写了一个未实现的空合约,下面去实现erc20的方法
作为一个Token 需要有 名称,标志,小数位,总数量
这边我们定义Token名称 Buff Token , 标志 BUFF , 总量 1000000000(1B) 一亿个
小数位 5
此外我们需要
一个mapping 来存储地址对应的token值(balances)
一个mapping 来存储地址用户的token授权(allowed)

PS: mapping 可以理解为Java的Map

```
contract BuffToken is ERC20Interface {
    string public symbol = "Buff Token";
    string public  name = "BUFF";
    uint8 public decimals = 5;
    // 数量需要算上小数位
    uint public _totalSupply = 100000000 * 10 ** uint256(decimals);
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function BuffToken(){

    }
}
```

接着我们开始实现方法
name , symbol , decimals 可选

首先 totalSupply,直接返回_totalSupply

```
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
```

balanceOf:查询address的余额

```
function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

```

allowance:查询spender在tokenOwner可用授权额度

```
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
```

transfer:转移调用者的token至地址to
这一步,我发现需要对token数量进行计算,这是我们需要引进SalfMath,以太坊爆出大量漏洞都是数值溢出,所以我们需要一个计算相关的简单库


SafeMath, 可以作为合约导入,也可以作为library导入
我们作为合约导入
      
```
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

```

transfer 相关代码
执行者减少token
目标地址增加token
触发Transfer event
由于使用了uint类型所以无需校验用户token是否足够


```
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
```

approve:执行者授权给spender指定额度的token的使用权,并触发Approval event

```
    function approve(address spender, uint tokens) public lockable returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
```

transferFrom:从from地址转出指定数量的token至to地址,
需校验执行者的授权额度
触发Transfer event

```
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }

```

至此我们可以创建一个有基础转账功能的ERC20 Token


