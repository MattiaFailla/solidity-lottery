from brownie import Lottery, accounts, config, network
from web3 import Web3


def test_get_entrance_fee():
    account = accounts[0]
    price_feed_contract_address = config["networks"][network.show_active()][
        "eth_usd_price_feed"
    ]
    lottery = Lottery.deploy(
        price_feed_contract_address,
        {"from": account},
    )
    # @note: We need to pull this data from an external api
    assert lottery.getEntranceFee() > Web3.toWei(0.014, "ether")
    assert lottery.getEntranceFee() < Web3.toWei(0.1, "ether")
