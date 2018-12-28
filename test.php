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
        return "hi";
    }

    /**
     * protected Declaration of func blue
     *
     * @return string
     */
    protected function blue(): string
    {
        return "hi";
    }
}
