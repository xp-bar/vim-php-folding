<?php

namespace Test;

class Test
{
    /**
     * Hello!
     * this is a multiline description!
     * have as many lines as you want
     *
     * @return string
     */
    public function thisfuncnameisverylongtestFunc(): string
    {
        return "hi";
    }

    /**
     * Declaration of func blue
     */
    public function blue()
    {
        $test->func()
            ->function()
            ->test()
            ->indent();

        $func = function () {
            $multiple = "lines";

            return "Test";
        };

        $array = [
            "test",
            "test",
            "test",
            "test",
            "test"
        ];

        return "hi";
    }

    /**
     * protected Declaration of func blue
     *
     * @return string
     */
    protected function blue(): string
    {
        $this->function();
        $this->function();
        $this->function();

        return "hi";
    }
}
